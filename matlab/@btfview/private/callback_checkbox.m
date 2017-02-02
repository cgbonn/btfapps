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
% React to checkbox clicks in the GUI.
function obj = callback_checkbox(obj, ch, evnt) %#ok<INUSD>
    val = get(ch, 'Value');
    switch ch
        case obj.handles.ch_crosshair
            obj.crosshair = val;
        case obj.handles.ch_fixed_aspect_ratio
            obj.fixed_aspect_ratio = val;
            if obj.fixed_aspect_ratio
                set(obj.handles.ah_texture, 'PlotBoxAspectRatio', [1, 1, 1]);
                set(obj.handles.ah_abrdf, 'PlotBoxAspectRatio', [1, 1, 1]);
            else
                set(obj.handles.ah_texture, 'PlotBoxAspectRatioMode', 'auto');
                set(obj.handles.ah_abrdf, 'PlotBoxAspectRatioMode', 'auto');
            end
        case obj.handles.ch_logarithm
            obj.logarithm = val;
        case obj.handles.ch_normalize
            obj.normalize = val;
        case obj.handles.ch_only_buffered
            obj.only_use_buffered = val;
            obj.update_btf();
        case obj.handles.ch_show_only_roi
            obj.show_only_roi = val;
        case obj.handles.ch_textures_from_file
            obj.textures_from_file = val;
            obj.update_btf();
        case obj.handles.ch_texture_psd
            obj.show_texture_psd = val;
        case obj.handles.ch_abrdf_psd
            obj.show_abrdf_psd = val;
        case obj.handles.ch_wrap_texture
            obj.wrap_around_texture = val;
        case obj.handles.ch_divide_cosine
            obj.divide_cosine = val;
        case obj.handles.ch_spec_normalize
            obj.normalize_spectrum = val;
        case obj.handles.ch_fancy_progress
            obj.fancy_progress = val;
    end
    force_reload = true;
    obj.show_texture(force_reload);
    obj.show_abrdf();
end
