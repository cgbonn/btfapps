% *************************************************************************
% * Copyright 2015 University of Bonn
% *
% * authors:
% *  - Sebastian Merzbach <merzbach@cs.uni-bonn.de>
% *
% * last modification date: 2016-04-05
% *
% * This file is part of btfapps.
% *
% * btfapps is free software: you can redistribute it and/or modify it
% * under the terms of the GNU General Public License as published by the
% * Free Software Foundation, either version 3 of the License, or (at your
% * option) any later version.
% *
% * btfapps is distributed in the hope that it will be useful, but WITHOUT
% * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
% * for more details.
% *
% * You should have received a copy of the GNU General Public License along
% * with btfapps. If not, see <http://www.gnu.org/licenses/>.
% *
% *************************************************************************
%
% This class provides a graphical interface for inspecting Bidirectional
% Texture Functions (BTFs), as those measured in the BTFDBB of Bonn
% University [1]. It relies on the btf class from btflib [2] and on the GUI
% Layout Toolbox [3, 4] for MATLAB. Furthermore, for export of untonemapped
% textures or ABRDFs, exrwrite from Micah Kimo Johnson's EXR library [5]
% is required.
%
% The GUI has functionality for interactive inspection, export of
% (tonemapped) textures and ABRDF views, cropping and export of the loaded
% BTFs themselves.
%
% Usage is simple: either provide a single file name, a cell array of file
% names or a cell array of btf objects as input to btfview.
%
% [1] http://cg.cs.uni-bonn.de/en/projects/btfdbb/
% [2] https://github.com/cgbonn/btflib/
% [3] MATLAB >= 2014b: http://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox/
% [4] MATLAB < 2014b: http://www.mathworks.com/matlabcentral/fileexchange/27758-gui-layout-toolbox
% [5] http://www.mit.edu/~kimo/software/matlabexr/

% TODO:

% export:
% - add GUI elements for doi (directions of interest) & subsampling ("every n-th
%   sample", "subsample every theta ring", both separately for light and view

% display / GUI:
% - add set_x, set_y, set_l, set_v methods that will handle GUI updates
% - add panel for meta information, like resolution, sampling, compression
%   parameters
% - fix display & size of progress bar; add cancel button?
% - switch off reading from file, when a BDI is newly selected?
% - add edit boxes for selecting x, y, l, v
% - extract roi from textures so that it can be wrapped around in
%   show-only-ROI mode
% - find a way to disable the global keyboard callbacks when typing in a edit box

classdef btfview < handle
    properties (Access = public)
        fancy_progress = true; % set this to false if you get errors regarding java swing
    end
    
    properties (GetAccess = public, SetAccess = protected)
        % GUI handles
        handles;
    end
    
    properties (Access = public, Constant = true)
        default_scale = 1; % linear scaling of texture
        default_gamma = 1; % gamma correction
        default_offset_color = 0; % color offset
    end

    properties (Access = protected)
        btfs; % cell array of BTFs

        width; % texture width of currently displayed BTF
        height; % texture width of currently displayed BTF
        num_channels; % number of color channels of currently displayed BTF
        num_lights; % number of light samples of currently displayed BTF
        num_views; % number of view samples of currently displayed BTF
        wavelengths; % wavelength sampling in case of a spectral BTF

        x = 1; % horizontal texture index
        y = 1; % vertical texture index
        l = 1; % light index
        v = 1; % view index
        current_l = -1; % stores the currently selected light index (avoids texture reloading)
        current_v = -1; % stores the currently selected view index (avoids texture reloading)
        b = 1; % index of btf
        offset_x = 0; % offsets in texture space, can be used to move the
        offset_y = 0; % texture and check for tiling artifacts
        prev_x = 1; % helper variable to compute relative cursor offsets
        prev_y = 1; % helper variable to compute relative cursor offsets
        roi = []; % region of interest in textures
        roi_stride = []; % offsets inside region of interest

        key_mod = ''; % currently pressed function key
        sel_type = ''; % currently pressed mouse button

        tonemapper; % tonemapper object that displays HDR and multispectral data
        normalize = false; % normalize each image/abrdf
        normalize_spectrum = true; % automatically choose axis limits in the spectrum plot
        logarithm = false; % take the logarithm for reducing the dynamic range

        wrap_around_texture = false; % wrap around if cursor is moved outside of texture axes
        fixed_aspect_ratio = true; % fixed or stretched aspect ratio
        textures_from_file = false; % disable loading textures from BDI files per default
        only_use_buffered = true; % disable loading textures missing in the buffer per default
        buffer_mem = 0.9; % percentage of free memory to allocate, if a BDI needs to be buffered
        current_texture; % buffers the currently selected texture to avoid long reloading from BDIs
        show_only_roi = false; % restrict the display to the selected ROI
        apply_roi = true; % when exporting BTFs, apply the selected ROI
        crosshair = true; % show current (x,y)- and (l,v)-positions with a crosshair?
        show_texture_psd = false; % show power spectral density instead of textures
        show_abrdf_psd = false; % show power spectral density of ABRDFs
        divide_cosine = false; % divide by cosine of theta_light
    end

    methods (Access = public)
        function obj = btfview(inp)
            % construct new viewer object from cell array of paths or btfs

            if ~iscell(inp)
                inp = {inp};
            end

            % load BTFs if necessary and toggle some fields in the btf objects
            for bi = 1 : numel(inp)
                if ~isa(inp{bi}, 'btf')
                    inp{bi} = btf(inp{bi});
                end

                % disable loading textures from BDIs, as this can take several
                % minutes per texture; this can be enabled via the GUI
                inp{bi}.textures_from_file(obj.textures_from_file);

                % set object verbosity and callback
                inp{bi}.set_verbose(true);
                inp{bi}.set_progress_callback(@obj.ui_callback_progress);
            end
            
            obj.btfs = inp;
            obj.update_btf();
            
            obj.tonemapper = tonemapper('scale', obj.default_scale, ...
                'gamma', obj.default_gamma, ...
                'offset', obj.default_offset_color);
            
            obj.ui_initialize();
            obj.show_abrdf();
            obj.show_texture();
            obj.ui_update_bdi_chunks();
        end

        function obj = save_images(obj)
            % export selected texture & ABRDF for current or all BTFs
            if ~exist(get(obj.handles.eh_export_dir, 'String'), 'dir')
                mkdir(get(obj.handles.eh_export_dir, 'String'));
            end

            % determine from which BTFs we export textures & ABRDFs
            if get(obj.handles.ch_save_all, 'Value')
                btf_inds = 1 : numel(obj.btfs);
            else
                btf_inds = obj.b;
            end

            for bi = btf_inds
                % generate output paths
                [~, file_base_name] = fileparts(obj.btfs{bi}.meta.file_name);
                if isempty(file_base_name)
                    file_base_name = sprintf('%s_%02d', obj.btfs{bi}.format_str, bi);
                end
                file_base_name = [file_base_name, '_', get(obj.handles.eh_export_suffix, 'String')]; %#ok<AGROW>

                abrdf_file_name = fullfile(get(obj.handles.eh_export_dir, 'String'), ...
                    sprintf('%s_abrdf_x%03d_y%03d', file_base_name, obj.x, obj.y));
                texture_file_name = fullfile(get(obj.handles.eh_export_dir, 'String'), ...
                    sprintf('%s_texture_l%03d_v%03d', file_base_name, obj.l, obj.v));

                % extract & tonemap textures & ABRDFs
                texture = obj.btfs{bi}.decode_texture(obj.l, obj.v);
                abrdf = obj.btfs{bi}.decode_abrdf(obj.x, obj.y);
                if get(obj.handles.ch_tonemap_images, 'Value')
                    texture = obj.tonemap(texture);
                    abrdf = obj.tonemap(abrdf);
                    imwrite(texture, [texture_file_name, '.png']);
                    imwrite(abrdf, [abrdf_file_name, '.png']);
                else
                    if exist('exrwrite', 'file') ~= 3
                        error('please download & install Micah Kimo Johnson''s EXR library: http://www.mit.edu/~kimo/software/matlabexr/');
                    end
                    exrwrite(double(abrdf), [abrdf_file_name, '.exr']);
                    exrwrite(double(texture), [texture_file_name, '.exr']);
                end
            end
        end

        function obj = save_btfs(obj)
            % save the selected or all BTF files, optionally with the selected ROI
            if ~exist(get(obj.handles.eh_export_dir, 'String'), 'dir')
                mkdir(get(obj.handles.eh_export_dir, 'String'));
            end

            % determine which BTFs to export
            if get(obj.handles.ch_save_all, 'Value')
                btf_inds = 1 : numel(obj.btfs);
            else
                btf_inds = obj.b;
            end

            for bii = 1 : numel(btf_inds)
                bi = btf_inds(bii);
                obj.ui_callback_progress(bii / numel(btf_inds), 'exporting BTFs');

                % generate output file path
                [~, file_base_name] = fileparts(obj.btfs{bi}.meta.file_name);
                if isempty(file_base_name)
                    file_base_name = sprintf('%s_%02d', obj.btfs{bi}.format_str, bi);
                end
                file_ext = 'btf';
                if strcmpi(obj.btfs{bi}.format_str, 'BDI')
                    file_ext = 'bdi';
                end
                output_path = fullfile(get(obj.handles.eh_export_dir, 'String'), ...
                    sprintf('%s_%s.%s', file_base_name, get(obj.handles.eh_export_suffix, 'String'), file_ext));

                % check for existing files
                if exist(output_path, 'file')
                    answer = questdlg(sprintf('File %s exists, overwrite?', output_path), 'file exists', 'Yes', 'No', 'No');
                    if strcmpi(answer, 'No')
                        [output_file_name, output_dir] = uiputfile('*.*', 'File exists', output_path);
                        output_path = fullfile(output_dir, output_file_name);
                    end
                end
                
                % extract ROI if requested
                if get(obj.handles.ch_apply_roi, 'Value') && ~isempty(obj.roi)
                    obj.btfs{bi}.crop(obj.roi, obj.roi_stride, output_path);
                end

                % update UI to show progress
                obj.b = bi;
                obj.update_btf();
                obj.show_texture();
                obj.show_abrdf();
                drawnow;

                if ~obj.btfs{bi}.is_bdi()
                    % cropped BDI has already been written
                    obj.btfs{obj.b}.write(output_path);
                end
            end
            obj.roi_sanity_checks();
            obj.ui_callback_progress();
        end
    end

    methods (Access = protected)
        function update_btf(obj)
            % load important meta data for currently selected BTF

            % force update to texture buffer
            obj.current_l = -1;
            obj.current_l = -1;

            % BDI: enable or disable loading of textures
            obj.btfs{obj.b}.textures_from_file(obj.textures_from_file);
            obj.btfs{obj.b}.only_use_buffered(obj.only_use_buffered);

            % update viewer object if another BTF has been selected
            obj.width = obj.btfs{obj.b}.meta.width;
            obj.height = obj.btfs{obj.b}.meta.height;
            obj.num_lights = obj.btfs{obj.b}.meta.nL;
            obj.num_views = obj.btfs{obj.b}.meta.nV;
            obj.num_channels = obj.btfs{obj.b}.meta.num_channels;
            if isfield(obj.btfs{obj.b}.meta, 'wavelengths') && ...
                    isnumeric(obj.btfs{obj.b}.meta.wavelengths)
                obj.wavelengths = obj.btfs{obj.b}.meta.wavelengths;
            elseif obj.num_channels ~= 3
                error(['For non-RGB BTFs the wavelength sampling must be ', ...
                    'specified in the meta struct in the field ''wavelengths''']);
            else
                obj.wavelengths = {'R', 'G', 'B'};
            end
            
            obj.update_axes();

            % BTF dimensions might have changed
            obj.roi_sanity_checks();
            
            % show/hide BDI-specific UI elements
            obj.ui_toggle_bdi();
            obj.ui_update_bdi_chunks();
        end
        
        function show_spectrum(obj)
            % show a bar plot of the currently selected texel's spectrum
            % (or RGB values)
            if ~strcmpi('Spectrum', obj.handles.uix_tabpanel_options.TabTitles{...
                    obj.handles.uix_tabpanel_options.Selection})
                return;
            end
            
            % prepare bar plot
            if obj.btfs{obj.b}.is_spectral()
                bins = obj.btfs{obj.b}.meta.wavelengths;
                labels = cellfun(@num2str, num2cell(bins(:)), 'UniformOutput', false);
            elseif obj.btfs{obj.b}.meta.num_channels == 3
                bins = 1 : 3;
                labels = {'R'; 'G'; 'B'};
            else
                bins = 1 : obj.btfs{obj.b}.meta.num_channels;
                labels = repmat({'?'}, 1, obj.btfs{obj.b}.meta.num_channels);
            end
            
            % normalize y-axis?
            if obj.normalize_spectrum
                obj.handles.ah_spec.YLimMode = 'auto';
            else
                obj.handles.ah_spec.YLimMode = 'manual';
            end
            
            % get the spectrum & plot it
            cur_texel = obj.btfs{obj.b}.decode_texel(obj.x, obj.y, obj.l, obj.v);
            cur_color = obj.handles.ih_abrdf.CData(obj.l, obj.v, :);
            obj.handles.bh_spec = tb.bar2(obj.handles.bh_spec, bins, cur_texel(:)', ...
                'FaceColor', cur_color);
            
            % update x-axis labels
            if obj.btfs{obj.b}.is_spectral() || obj.btfs{obj.b}.meta.num_channels ~= 3
                obj.handles.ah_spec.XTickLabel = cellfun(@num2str, ...
                    num2cell(obj.handles.ah_spec.XTick), 'UniformOutput', false);
            else
                obj.handles.ah_spec.XTickLabel = labels;
            end
        end
        
        function update_axes(obj)
            % if the selecte BTF object changes, we might have to update
            % the texture and ABRDF axis limits
            if isfield(obj.handles, 'ah_texture') % init?
                w_new = obj.btfs{obj.b}.meta.width;
                h_new = obj.btfs{obj.b}.meta.height;
                obj.handles.ih_texture = tb.imshow2(obj.handles.ih_texture, ...
                    zeros(h_new, w_new, 3));
                
                nl_new = obj.btfs{obj.b}.meta.nL;
                nv_new = obj.btfs{obj.b}.meta.nV;
                obj.handles.ih_abrdf = tb.imshow2(obj.handles.ih_abrdf, ...
                    zeros(nl_new, nv_new, 3));
            end
        end
        
        function obj = autoscale(obj)
            % estimate global color limits by sampling some ABRDFs
            mid_x = round(obj.width / 2);
            mid_y = round(obj.height / 2);
            xs = [1, mid_x, obj.width];
            ys = [1, mid_y, obj.height];
            clims = [inf, -inf];
            for ii = 1 : numel(xs)
                clims_tmp = prctile(obj.btfs{obj.b}.decode_abrdf(xs(ii), ys(ii)), [0, 100]);
                clims(1) = min(clims(1), clims_tmp(1));
                clims(2) = max(clims(2), clims_tmp(2));
            end
            obj.tonemapper.offset = clims(1);
            obj.tonemapper.scale = 1 / (clims(2) - obj.tonemapper.offset);
            set(obj.handles.eh_gamma, 'String', sprintf('%.2f', obj.tonemapper.gamma));
            set(obj.handles.eh_offset, 'String', sprintf('%.2f', obj.tonemapper.offset));
            set(obj.handles.eh_scale, 'String', sprintf('%.2f', obj.tonemapper.scale));
        end

        function image = tonemap(obj, image)
            % Prepares image data for display.
            % Applies an offset, linear scaling, gamma-correction and clamping
            % on the data. Parameters:
            %   image: arbitrarily sized image data
            
            if obj.logarithm
                image = log(image);
            end
            
            if obj.normalize
                image_min = min(image(:));
                image_max = max(image(:));
                image = (image - image_min) / (image_max - image_min);
            end
            
            image = img(image, 'channel_names', obj.wavelengths);
            image = obj.tonemapper.tonemap(image);
        end

        function obj = show_texture(obj, force_reload)
            % load texture from BTF;
            % for BDIs this might result in black textures, as reading textures
            % from BDI files is extremely slow and is disabled by default
            
            if ~exist('force_reload', 'var')
                force_reload = false;
            end

            obj.l = max(1, min(obj.num_lights, obj.l));
            obj.v = max(1, min(obj.num_views, obj.v));

            % only reload texture when needed
            if force_reload || obj.current_l ~= obj.l || obj.current_v ~= obj.v
                obj.btfs{obj.b}.set_cosine_flag(obj.divide_cosine);
                obj.current_texture = obj.btfs{obj.b}.decode_texture(int32(obj.l), int32(obj.v));
                obj.current_l = obj.l;
                obj.current_v = obj.v;
            end
            
            if obj.show_texture_psd
                % compute FFT of texture's intensity
                texture = fft2(mean(obj.current_texture, 3));
                
                % remove DC coefficient (this is usually much higher and
                % prohibits nice display of the FFT)
                texture(1, 1) = min(texture(:));
                
                % compute power spectral density
                texture = abs(fftshift(texture)) .^ 2;
                
                % apply tonemapping for display
                texture = obj.tonemap(repmat(texture, [1, 1, 3]));
            else
                texture = obj.tonemap(obj.current_texture);
            end

            % shift image
            texture = utils.imshift(texture, obj.offset_x, obj.offset_y);

            % add annotation
            for annh = obj.handles.annot_texture
                try %#ok<TRYNC>
                    delete(annh{1});
                end
            end
            if obj.crosshair
                if ~isempty(obj.roi) && obj.show_only_roi
                    obj.handles.annot_texture = utils.imannotate(obj.handles.ah_texture, ...
                        mod(obj.x + obj.offset_x - 1, obj.width) + 1, ...
                        mod(obj.y + obj.offset_y - 1, obj.height) + 1, 'g-', 3, 5, ...
                        sprintf('(%d,%d)', obj.x, obj.y), 'g');
                else
                    obj.handles.annot_texture = utils.imannotate(obj.handles.ah_texture, ...
                        mod(obj.x + obj.offset_x - 1, obj.width) + 1, ...
                        mod(obj.y + obj.offset_y - 1, obj.height) + 1, 'g-', 3, 5, ...
                        sprintf('(%d,%d)', obj.x, obj.y), 'g');
                end
            end

            % if set, paint the region of interest in the texture
            try %#ok<TRYNC>
                delete(obj.handles.roi{1});
            end
            if ~isempty(obj.roi) && ~obj.show_only_roi
                obj.handles.roi = utils.imroi2(obj.handles.ah_texture, ...
                    obj.roi(1, 1), obj.roi(2, 1), obj.roi(1, 2), obj.roi(2, 2), 'g-');
            end

            % actually display the tonemapped image
            texture = utils.clamp(texture);
            obj.handles.ih_texture = tb.imshow2(obj.handles.ih_texture, texture);

            % show only cropped region in texture view
            if obj.show_only_roi
                set(obj.handles.ah_texture, 'XLim', [obj.roi(1, 1) - 0.5, obj.roi(1, 2) + 0.5]);
                set(obj.handles.ah_texture, 'YLim', [obj.roi(2, 1) - 0.5, obj.roi(2, 2) + 0.5]);
            else
                set(obj.handles.ah_texture, 'XLim', [0.5, obj.width + 0.5]);
                set(obj.handles.ah_texture, 'YLim', [0.5, obj.height + 0.5]);
            end

            % update status UI
            [l_in, l_az, v_in, v_az] = obj.btfs{obj.b}.inds_to_angles(obj.l, obj.v);
            set(obj.handles.th_texture, 'String', ...
                sprintf('(Lpol,Laz)=(%.1f,%.1f), (Vpol,Vaz)=(%.1f,%.1f), (L,V)=(%d,%d)', ...
                l_in, l_az, v_in, v_az, obj.l, obj.v));

            % we need to update the plotted directions when the texture changes
            if ~obj.handles.uix_boxpanel_sampling.IsMinimized
                obj.show_light_view_dirs();
            end
        end

        function obj = show_abrdf(obj)
            % load ABRDF from BTF
            obj.x = max(1, min(obj.width, obj.x));
            obj.y = max(1, min(obj.height, obj.y));

            obj.btfs{obj.b}.set_cosine_flag(obj.divide_cosine);
            
            if obj.show_abrdf_psd
                % compute FFT of texture's intensity
                abrdf = fft2(mean(obj.btfs{obj.b}.decode_abrdf(obj.x, obj.y), 3));
                
                % remove DC coefficient (this is usually much higher and
                % prohibits nice display of the FFT)
%                 abrdf(1, 1) = min(abrdf(:));
                
                % compute power spectral density
                abrdf = abs(fftshift(abrdf)) .^ 2;
                
                % apply tonemapping for display
                abrdf = obj.tonemap(repmat(abrdf, [1, 1, 3]));
            else
                abrdf = obj.tonemap(obj.btfs{obj.b}.decode_abrdf(obj.x, obj.y));
            end

            % add annotation
            for annh = obj.handles.annot_abrdf
                try %#ok<TRYNC>
                    delete(annh{1});
                end
            end
            if obj.crosshair
                obj.handles.annot_abrdf = utils.imannotate(obj.handles.ah_abrdf, ...
                    obj.v, obj.l, 'g-', 2, 3, sprintf('(%d,%d)', obj.l, obj.v), 'g');
            end

            % actually display the tonemapped image
            obj.handles.ih_abrdf = tb.imshow2(obj.handles.ih_abrdf, abrdf);

            % update status UI
            set(obj.handles.th_abrdf, 'String', sprintf('(x,y)=(%d,%d)', obj.x, obj.y));
        end

        function obj = show_hemisphere(obj)
            % show the BTF's angular sampling on the hemisphere
            res = 20;

            % create coordinates of a unit sphere with the desired resolution
            [sph_x, sph_y, sph_z] = sphere(res);
            % only use upper hemisphere
            sph_x = sph_x(ceil(res / 2 + 1) : end, :);
            sph_y = sph_y(ceil(res / 2 + 1) : end, :);
            sph_z = sph_z(ceil(res / 2 + 1) : end, :);

            obj.handles.handles_sampling = cell(1, 6);
            obj.handles.handles_sampling{1} = mesh(obj.handles.ah_sampling, sph_x, sph_y, sph_z, 'EdgeAlpha', 0.5, 'FaceColor', 'none');
            hold(obj.handles.ah_sampling, 'on');
            axis(obj.handles.ah_sampling, 'equal');
            cp = campos(obj.handles.ah_sampling);
            campos(obj.handles.ah_sampling, [7, 1, 10]);

            obj.show_light_view_dirs(true);

            set(obj.handles.ah_sampling, 'XTick', [], 'YTick', [], 'ZTick', [], ...
                'XGrid', 'off', 'YGrid', 'off', 'ZGrid', 'off', ...
                'XColor', 'k', 'YColor', 'k', 'ZColor', 'k', ...
                'Box', 'off', 'Color', 'k', ...
                'ActivePositionProperty', 'Position');
            set(obj.handles.uix_boxpanel_sampling, 'BackgroundColor', 'k');
        end

        function obj = show_light_view_dirs(obj, init)
            % plot vectors pointing to the direction of light and cameras
            if ~exist('init', 'var')
                init = false;
            end

            % show the currently selected L/V-directions
            if ~obj.handles.uix_boxpanel_sampling.IsMinimized || init
                [tl, pl, tv, pv] = obj.btfs{obj.b}.inds_to_angles(obj.l, obj.v);

                res = 20;
                polringv = [repmat(tv, res, 1), linspace(0, 2 * pi, res)'];
                polringl = [repmat(tl, res, 1), linspace(0, 2 * pi, res)'];

                xyzv = utils.sph2cart2([tv, pv]);
                xyzl = utils.sph2cart2([tl, pl]);
                xyzringv = utils.sph2cart2(polringv);
                xyzringl = utils.sph2cart2(polringl);

                th0 = pi / 2;
                ph0 = 0;
                xyz0 = utils.sph2cart2([th0, ph0]);

                names = {'\phi=0', ...
                    ['\omega_V=(\theta_V=' num2str(tv) ',\phi_V=' num2str(pv) ')'],...
                    ['omega_L=(\theta_L=' num2str(tl) ',\phi_L=' num2str(pl) ')']};
                colors = {[0.5, 0.5, 0.5], [0, 0.75, 0.75], [0.8, 0.8, 0.2]};

                % clear previously rendered objects
                for h = 2 : numel(obj.handles.handles_sampling)
                    delete(obj.handles.handles_sampling{h});
                end
                
                plot_vec = @(xyz_from, xyz_to, line_width, name, color) plot3(obj.handles.ah_sampling, ...
                    [-xyz_from(1), -xyz_from(1) - xyz_to(1)], ...
                    [xyz_from(2), xyz_from(2) + xyz_to(2)], ...
                    [xyz_from(3), xyz_from(3) + xyz_to(3)], ...
                    'LineWidth', line_width, ...
                    'Color', color, 'DisplayName', name);
                plot_ring = @(xyz, line_width, color) plot3(obj.handles.ah_sampling, ...
                    -xyz(:, 1), xyz(:, 2), xyz(:, 3), ...
                    'LineWidth', line_width, 'Color', color);

                % indicate azimuth 0 degree
                obj.handles.handles_sampling{2} = plot_vec([0, 0, 0], xyz0, 1, names{1}, colors{1});
                hold(obj.handles.ah_sampling, 'all');
                % view vector points outwards
                obj.handles.handles_sampling{3} = plot_vec([0, 0, 0], xyzv, 2, names{2}, colors{2});
                % light vector points inwards
                obj.handles.handles_sampling{4} = plot_vec(xyzl, -xyzl, 2, names{3}, colors{3});
                % also plot theta rings to improve recognizability
                obj.handles.handles_sampling{5} = plot_ring(xyzringv, 1, colors{2});
                obj.handles.handles_sampling{6} = plot_ring(xyzringl, 1, colors{3});
            end
        end

        function obj = roi_sanity_checks(obj)
            % clamp selected region of interest to texture domain

            if isempty(obj.roi)
                return;
            end

            % limits ROI to texture space
            obj.roi(:, 1) = max(1, obj.roi(:, 1));
            obj.roi(1, 2) = max(obj.roi(1, 1), min(obj.width, obj.roi(1, 2)));
            obj.roi(2, 2) = max(obj.roi(2, 1), min(obj.height, obj.roi(2, 2)));

            % and also for strides
            if isempty(obj.roi_stride)
                obj.roi_stride = ones(2, 1);
            end
            roi_dims = obj.roi(:, 2) - obj.roi(:, 1) + 1;
            obj.roi_stride(1) = min(roi_dims(1), obj.roi_stride(1));
            obj.roi_stride(2) = min(roi_dims(2), obj.roi_stride(2));

            % update edit boxes
            for ii = 1 : 4
                set(obj.handles.eh_roi(ii), 'String', sprintf('%d', obj.roi(ii)));
            end
            set(obj.handles.eh_roi(1, 3), 'String', obj.roi_stride(1));
            set(obj.handles.eh_roi(2, 3), 'String', obj.roi_stride(2));
        end
    end
end
