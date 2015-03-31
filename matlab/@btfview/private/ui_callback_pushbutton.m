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
% React to pressed pushbutton.
function obj = ui_callback_pushbutton(obj, bh, evnt) %#ok<INUSD>
    switch bh
        case obj.handles.bh_autoscale
            obj.autoscale();
        case obj.handles.bh_buffer_bdi
            if obj.btfs{obj.b}.is_bdi()
                obj.btfs{obj.b}.buffer_bdi(obj.buffer_mem);
            end
            obj.update_btf();
        case obj.handles.bh_gamma
            obj.gamma = 1;
            set(obj.handles.eh_gamma,'String',sprintf('%.2f', obj.gamma));
        case obj.handles.bh_offset
            obj.offset_color = 0;
            set(obj.handles.eh_offset,'String',sprintf('%.2f', obj.offset_color));
        case obj.handles.bh_offsetXY
            obj.offset_x = 0;
            obj.offset_y = 0;
            obj.x = 1;
            obj.y = 1;
        case obj.handles.bh_open_dir
            tmp = uigetdir(get(obj.handles.eh_export_dir, 'String'), 'Export directory');
            if tmp ~= 0
                set(obj.handles.eh_export_dir, 'String', obj.export_dir);
            end
        case obj.handles.bh_reset_roi
            obj.roi = [];
            obj.roi_stride = [];
            for ii = 1 : 6
                set(obj.handles.eh_roi(ii), 'String', '');
            end
            if obj.show_only_roi
                obj.show_only_roi = false;
                obj.callback_checkbox(obj.handles.ch_show_only_roi);
            end
        case obj.handles.bh_save_btf
            obj.save_btfs();
        case obj.handles.bh_save_images
            obj.save_images();
        case obj.handles.bh_scale
            obj.scale = 1;
            set(obj.handles.eh_scale,'String',sprintf('%.2f', obj.scale));
    end
    obj.show_texture();
    obj.show_abrdf();
end
