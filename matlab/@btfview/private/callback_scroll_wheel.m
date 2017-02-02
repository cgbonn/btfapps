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
% React to scroll wheel events.
function obj = callback_scroll_wheel(obj, src, evnt) %#ok<INUSL>
    % scroll wheel
    switch obj.key_mod
        case 'control'
            if evnt.VerticalScrollCount == 1
                obj.tonemapper.scale = obj.tonemapper.scale / 1.25;
            else
                obj.tonemapper.scale = obj.tonemapper.scale * 1.25;
            end
            set(obj.handles.eh_scale, 'String', sprintf('%.2f', obj.tonemapper.scale));
        case 'shift'
            if evnt.VerticalScrollCount == 1
                obj.tonemapper.gamma = obj.tonemapper.gamma / 1.25;
            else
                obj.tonemapper.gamma = obj.tonemapper.gamma * 1.25;
            end
            set(obj.handles.eh_gamma, 'String', sprintf('%.2f', obj.tonemapper.gamma));
        case 'alt'
            if evnt.VerticalScrollCount == 1
                obj.tonemapper.offset = obj.tonemapper.offset - obj.tonemapper.scale / 50;
            else
                obj.tonemapper.offset = obj.tonemapper.offset + obj.tonemapper.scale / 50;
            end
            set(obj.handles.eh_offset, 'String', sprintf('%.2f', obj.tonemapper.offset));
        otherwise
            if evnt.VerticalScrollCount == -1
                obj.b = max(1, min(numel(obj.btfs), obj.b - 1));
            else
                obj.b = max(1, min(numel(obj.btfs), obj.b + 1));
            end
            set(obj.handles.lh_btfs, 'Value', obj.b);
            if obj.btfs{obj.b}.is_bdi()
                obj.handles.uix_disp_bdi_bp.Visible = 'on';
            else
                obj.handles.uix_disp_bdi_bp.Visible = 'off';
            end
            obj.update_btf();
    end
    obj.show_texture();
    obj.show_abrdf();
end
