% *************************************************************************
% * Copyright 2015 University of Bonn
% *
% * authors:
% *  - Sebastian Merzbach <merzbach@cs.uni-bonn.de>
% *
% * last modification date: 2015-03-31
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
% Set up all GUI layout and elements.
function obj = ui_initialize(obj)
    obj.handles.figure = figure('MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off');
    obj.handles.figure_abrdf = [];
    obj.handles.figure_texture = [];
    obj.handles.figure_sampling = [];
    obj.handles.figure_sampling = []; % extra figure that is used for visualization of angular sampling
    obj.handles.angular_handles = []; % plot object handles used for angular sampling visualization
    obj.handles.handles_3d = []; % handles of 3D ABRDF plot
    
    % set up layout
    obj.handles.uix_vbox_global = uix.VBox('Parent', obj.handles.figure, 'Spacing', 2); % full figure vertical box
    obj.handles.uix_hbox_upper = uix.HBoxFlex('Parent', obj.handles.uix_vbox_global, 'Spacing', 3); % upper horizontal box
    obj.handles.uix_status_box = uix.HBox('Parent', obj.handles.uix_vbox_global, 'Spacing', 5); % optionally displays a progress bar
    obj.handles.uix_hbox_lower = uix.HBoxFlex('Parent', obj.handles.uix_vbox_global, 'Spacing', 3); % lower horizontal box
    set(obj.handles.uix_vbox_global, 'Heights', [-1, 0, 130]);
    
    % create child containers in upper panels
    obj.handles.uix_vbox_upper_left = uix.VBoxFlex('Parent', obj.handles.uix_hbox_upper, 'Spacing', 3);
    obj.handles.uix_vbox_upper_right = uix.VBoxFlex('Parent', obj.handles.uix_hbox_upper, 'Spacing', 3);
    obj.handles.uix_boxpanel_texture = uix.BoxPanel('Parent', obj.handles.uix_vbox_upper_left, 'Title', 'textures', 'Padding', 15, 'HelpFcn', @(a,b) disp('textures (LMB: select, RMB: move, MMB: ROI, WHEEL + {ctrl,shift,alt}: tonemapping)'), 'DockFcn', @obj.uix_callback_dock);
    obj.handles.uix_boxpanel_abrdf = uix.BoxPanel('Parent', obj.handles.uix_vbox_upper_right, 'Title', 'ABRDFs', 'Padding', 15, 'HelpFcn', @(a,b) disp('ABRDFs (LMB: select)'), 'DockFcn', @obj.uix_callback_dock);
    obj.handles.uix_boxpanel_sampling = uix.BoxPanel('Parent', obj.handles.uix_vbox_upper_right, 'Title', 'angular sampling', 'DockFcn', @obj.uix_callback_dock, 'MinimizeFcn', @obj.uix_callback_minimize);
    set(obj.handles.uix_vbox_upper_left, 'Heights', -1);
    set(obj.handles.uix_vbox_upper_right, 'Heights', [-4, -3]);
    
    % create child containers in lower panels
    obj.handles.uix_panel_selection = uix.Panel('Parent', obj.handles.uix_hbox_lower, 'Title', 'select BTF');
    obj.handles.uix_tabpanel_options = uix.TabPanel('Parent', obj.handles.uix_hbox_lower); % lower tab panel
    set(obj.handles.uix_hbox_lower, 'Widths', [-1, -2]);
    
    % create child elements in status container
    if obj.fancy_progress
        obj.handles.java_progress_bar = javax.swing.JProgressBar;
        set(obj.handles.java_progress_bar, 'StringPainted', 1, 'Value', 10, 'Indeterminate', 0);
        obj.handles.pbh = javacomponent(obj.handles.java_progress_bar, [0, 0, 1, 1], obj.handles.uix_status_box);
    end
    obj.handles.th_status = uicontrol('Parent', obj.handles.uix_status_box, 'Style', 'text', 'String', '', 'HorizontalAlignment', 'left');
    if obj.fancy_progress
        set(obj.handles.uix_status_box, 'Widths', [400, -1]);
    end
    
    % fill upper panels
    obj.handles.ah_texture = axes('Parent', obj.handles.uix_boxpanel_texture, 'ActivePositionProperty', 'Position', 'XTick', [], 'YTick', [], 'PlotBoxAspectRatio', [1, 1, 1]);
    obj.handles.ah_abrdf = axes('Parent', obj.handles.uix_boxpanel_abrdf, 'ActivePositionProperty', 'Position', 'XTick',[], 'YTick', [], 'PlotBoxAspectRatio', [1, 1, 1]);
    obj.handles.ah_sampling = axes('Parent', obj.handles.uix_boxpanel_sampling, 'ActivePositionProperty', 'Position', 'PlotBoxAspectRatio', [1, 1, 1], 'Color', 'k');
    obj.show_hemisphere();
    obj.uix_callback_minimize(obj.handles.ah_sampling);
    
    % fill lower panels
    
    % BTF selection listbox
    [~, btf_strings] = cellfun(@(x) fileparts(x.meta.file_name), obj.btfs, 'UniformOutput', false);
    for bi = 1 : numel(obj.btfs)
        if isempty(btf_strings{bi})
            btf_strings{bi} = sprintf('%s_%03d', obj.btfs{bi}.format_str, bi);
        end
    end
    obj.handles.lh_btfs = uicontrol('Parent', obj.handles.uix_panel_selection, 'Style', 'listbox', 'String', btf_strings, 'Callback', @obj.ui_callback_listbox);
    
    % set up tabs
    obj.handles.uix_tm_ho = uix.HBox('Parent', obj.handles.uix_tabpanel_options); % tonemapping horizontal box
    obj.handles.uix_exp_grid = uix.Grid('Parent', obj.handles.uix_tabpanel_options); % export grid layout
    obj.handles.uix_disp_ho = uix.HBox('Parent', obj.handles.uix_tabpanel_options); % display horizontal box
    set(obj.handles.uix_tabpanel_options, 'TabTitles', {'Tonemapping', 'Export', 'Display'}, 'TabWidth', 75);
    
    % fill tabs for tonemapping, export, ...
    obj.handles.uix_tm_bb1 = uix.VButtonBox('Parent', obj.handles.uix_tm_ho);
    obj.handles.uix_tm_bb2 = uix.VButtonBox('Parent', obj.handles.uix_tm_ho);
    obj.handles.uix_tm_bb3 = uix.VButtonBox('Parent', obj.handles.uix_tm_ho);
    obj.handles.uix_disp_bb1 = uix.VButtonBox('Parent', obj.handles.uix_disp_ho);
    obj.handles.uix_disp_vb = uix.VBox('Parent', obj.handles.uix_disp_ho);
    obj.handles.uix_disp_bb2 = uix.VButtonBox('Parent', obj.handles.uix_disp_vb);
    obj.handles.uix_disp_bb2_gr = uix.Grid('Parent', obj.handles.uix_disp_vb);
    obj.handles.uix_disp_bdi_bp = uix.BoxPanel('Parent', obj.handles.uix_disp_ho, 'Title', 'BDI');
    obj.handles.uix_disp_ho_bdi = uix.HBox('Parent', obj.handles.uix_disp_bdi_bp);
    obj.handles.uix_disp_bb_bdi1 = uix.VButtonBox('Parent', obj.handles.uix_disp_ho_bdi);
    obj.handles.uix_disp_bb_bdi2 = uix.VButtonBox('Parent', obj.handles.uix_disp_ho_bdi);
    set(obj.handles.uix_disp_ho, 'Widths', [115, 125, -1]);
    
    % tonemapping tab
    % first column
    uicontrol('Parent',obj.handles.uix_tm_bb1, 'Style', 'text', 'String', 'Scale:', 'HorizontalAlignment', 'right');
    uicontrol('Parent',obj.handles.uix_tm_bb1, 'Style', 'text', 'String', 'Gamma:', 'HorizontalAlignment', 'right');
    uicontrol('Parent',obj.handles.uix_tm_bb1, 'Style', 'text', 'String', 'Offset:', 'HorizontalAlignment', 'right');
    
    % second column
    obj.handles.eh_scale = uicontrol('Parent', obj.handles.uix_tm_bb2, 'Style', 'edit', 'String', sprintf('%.2f', obj.scale), 'Callback', @obj.ui_callback_edit);
    obj.handles.eh_gamma = uicontrol('Parent', obj.handles.uix_tm_bb2, 'Style', 'edit', 'String', sprintf('%.2f', obj.gamma), 'Callback', @obj.ui_callback_edit);
    obj.handles.eh_offset = uicontrol('Parent', obj.handles.uix_tm_bb2, 'Style', 'edit', 'String', sprintf('%.2f', obj.offset_color), 'Callback', @obj.ui_callback_edit);
    obj.handles.ch_normalize = uicontrol('Parent', obj.handles.uix_tm_bb2, 'Style', 'checkbox', 'String', 'normalize', 'Value', obj.normalize, 'Callback', @obj.callback_checkbox);
    
    % third column
    obj.handles.bh_scale = uicontrol('Parent', obj.handles.uix_tm_bb3, 'Style', 'pushbutton', 'String', 'Reset scaling', 'Callback', @obj.ui_callback_pushbutton);
    obj.handles.bh_gamma = uicontrol('Parent', obj.handles.uix_tm_bb3, 'Style', 'pushbutton', 'String', 'Reset gamma', 'Callback', @obj.ui_callback_pushbutton);
    obj.handles.bh_offset = uicontrol('Parent', obj.handles.uix_tm_bb3, 'Style', 'pushbutton', 'String', 'Reset color offset', 'Callback', @obj.ui_callback_pushbutton);
    obj.handles.bh_autoscale = uicontrol('Parent', obj.handles.uix_tm_bb3, 'Style', 'pushbutton', 'String', 'autoscale', 'Callback', @obj.ui_callback_pushbutton);
    
    % set up sizes of tonemapping containers
    set(obj.handles.uix_tm_bb1, 'ButtonSize', [60, 20]);
    set(obj.handles.uix_tm_bb2, 'ButtonSize', [85, 20]);
    set(obj.handles.uix_tm_bb3, 'ButtonSize', [125, 20]);
    set(obj.handles.uix_tm_ho, 'Widths', [65, 90, 130]);
    
    % export tab
    obj.handles.bh_save_images = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'pushbutton', 'String', 'save images', 'Callback', @obj.ui_callback_pushbutton);
    obj.handles.bh_save_btf = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'pushbutton', 'String', 'save BTF', 'Callback', @obj.ui_callback_pushbutton);
    uix.Empty('Parent', obj.handles.uix_exp_grid);
    uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'text', 'String', 'name suffix:');
    uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'text', 'String', 'export directory:');
    obj.handles.ch_tonemap_images = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'checkbox', 'String', 'tonemap images', 'Value', true, 'Callback', @obj.callback_checkbox);
    obj.handles.ch_apply_roi = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'checkbox', 'String', 'apply ROI', 'Value', obj.apply_roi, 'Callback', @obj.callback_checkbox);
    obj.handles.ch_save_all = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'checkbox', 'String', 'save all loaded', 'Value', false, 'Callback', @obj.callback_checkbox);
    obj.handles.eh_export_dir = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'edit', 'String', fileparts(obj.btfs{obj.b}.meta.file_name), 'HorizontalAlignment', 'left', 'Callback', @obj.ui_callback_edit);
    obj.handles.eh_export_suffix = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'edit', 'String', 'tonemapped', 'HorizontalAlignment', 'left', 'Callback', @obj.ui_callback_edit);
    uix.Empty('Parent', obj.handles.uix_exp_grid);
    uix.Empty('Parent', obj.handles.uix_exp_grid);
    uix.Empty('Parent', obj.handles.uix_exp_grid);
    obj.handles.bh_open_dir = uicontrol('Parent', obj.handles.uix_exp_grid, 'Style', 'pushbutton', 'String', 'open', 'Callback', @obj.ui_callback_pushbutton);
    uix.Empty('Parent', obj.handles.uix_exp_grid);
    set(obj.handles.uix_exp_grid, 'Widths', [130, 200, 50], 'Heights', [20, 20, 20, 20, 20]);
    
    % display tab
    % general display related options
    obj.handles.bh_offsetXY = uicontrol('Parent', obj.handles.uix_disp_bb1, 'Style', 'pushbutton', 'String', 'reset xy offsets', 'Callback', @obj.ui_callback_pushbutton);
    obj.handles.ch_wrap_texture = uicontrol('Parent', obj.handles.uix_disp_bb1, 'Style', 'checkbox', 'String', 'wrap cursor', 'Value', obj.wrap_around_texture, 'Callback', @obj.callback_checkbox);
    obj.handles.ch_fixed_aspect_ratio = uicontrol('Parent', obj.handles.uix_disp_bb1, 'Style', 'checkbox', 'String', 'fix asp. ratio', 'Value', obj.fixed_aspect_ratio, 'Callback', @obj.callback_checkbox);
    obj.handles.ch_crosshair = uicontrol('Parent', obj.handles.uix_disp_bb1, 'Style', 'checkbox', 'String', 'crosshair', 'Value', obj.crosshair, 'Callback', @obj.callback_checkbox);
    set(obj.handles.uix_disp_bb1, 'ButtonSize', [110, 20]);
    
    % ROI selection
    % first column (labels)
    uix.Empty('Parent', obj.handles.uix_disp_bb2_gr);
    uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'text', 'String', 'x');
    uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'text', 'String', 'y');
    % second column (minima)
    uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'text', 'String', 'min');
    obj.handles.eh_roi(1, 1) = uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'edit', 'String', '', 'Callback', @obj.ui_callback_edit);
    obj.handles.eh_roi(2, 1) = uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'edit', 'String', '', 'Callback', @obj.ui_callback_edit);
    % second column (stride)
    uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'text', 'String', 'offs.');
    obj.handles.eh_roi(1, 3) = uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'edit', 'String', '', 'Callback', @obj.ui_callback_edit);
    obj.handles.eh_roi(2, 3) = uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'edit', 'String', '', 'Callback', @obj.ui_callback_edit);
    % third column (maxima)
    uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'text', 'String', 'max');
    obj.handles.eh_roi(1, 2) = uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'edit', 'String', '', 'Callback', @obj.ui_callback_edit);
    obj.handles.eh_roi(2, 2) = uicontrol('Parent', obj.handles.uix_disp_bb2_gr, 'Style', 'edit', 'String', '', 'Callback', @obj.ui_callback_edit);
    set(obj.handles.uix_disp_bb2_gr, 'Widths', [10, 30, 30, 30], 'Heights', [15, 15, 15]);
    
    % other ROI related UI
    obj.handles.ch_show_only_roi = uicontrol('Parent', obj.handles.uix_disp_bb2, 'Style', 'checkbox', 'String', 'show only ROI', 'Value', obj.show_only_roi, 'Callback', @obj.callback_checkbox);
    obj.handles.bh_reset_roi = uicontrol('Parent', obj.handles.uix_disp_bb2, 'Style', 'pushbutton', 'String', 'clear ROI', 'Callback', @obj.ui_callback_pushbutton);
    set(obj.handles.uix_disp_bb2, 'ButtonSize', [120, 20]);
    
    % BDI-specific UI elements
    obj.handles.ch_textures_from_file = uicontrol('Parent', obj.handles.uix_disp_bb_bdi1, 'Style', 'checkbox', 'String', 'read from file', 'Value', obj.textures_from_file, 'Callback', @obj.callback_checkbox);
    obj.handles.ch_only_buffered = uicontrol('Parent', obj.handles.uix_disp_bb_bdi1, 'Style', 'checkbox', 'String', 'buffered only', 'Value', obj.only_use_buffered, 'Callback', @obj.callback_checkbox);
    obj.handles.uix_disp_bdi_bb_ho = uix.HBox('Parent', obj.handles.uix_disp_bb_bdi2);
    obj.handles.eh_buffer_mem = uicontrol('Parent', obj.handles.uix_disp_bdi_bb_ho, 'Style', 'edit', 'String', sprintf('%.1f', 100 * obj.buffer_mem), 'Callback', @obj.ui_callback_edit);
    uicontrol('Parent', obj.handles.uix_disp_bdi_bb_ho, 'Style', 'text', 'String', '% free RAM', 'HorizontalAlignment', 'left');
    set(obj.handles.uix_disp_bdi_bb_ho, 'Widths', [30, 60]);
    obj.handles.bh_buffer_bdi = uicontrol('Parent', obj.handles.uix_disp_bb_bdi2, 'Style', 'pushbutton', 'String', 'buffer BDI', 'Callback', @obj.ui_callback_pushbutton);
    set(obj.handles.uix_disp_bb_bdi1, 'ButtonSize', [85, 20]);
    set(obj.handles.uix_disp_bb_bdi2, 'ButtonSize', [90, 20]);
    
    % set visibility of BDI-specific UI elements
    obj.ui_toggle_bdi();
    
    % TODO: integrate this into the main figure (maybe as dockable containers)
    obj.handles.ah_angular = []; % axes used for visualization of angular sampling
    
    obj.ui_init_axes();
    obj.ui_set_callbacks();
end
