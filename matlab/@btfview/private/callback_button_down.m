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
% React to pressed mouse button.
function obj = callback_button_down(obj, src, evnt) %#ok<INUSD>
    % mouse button down
    obj.sel_type = get(obj.handles.figure, 'SelectionType');
    if src == obj.handles.ih_abrdf
        % mouse button down inside ABRDF view
        if obj.handles.uix_boxpanel_abrdf.Docked
            set(obj.handles.figure,'WindowButtonMotionFcn',{@obj.callback_motion,obj.handles.ah_abrdf});
            set(obj.handles.figure,'WindowKeyPressFcn',{@obj.callback_key_press,obj.handles.ah_abrdf});
        else
            set(obj.handles.figure_abrdf,'WindowButtonMotionFcn',{@obj.callback_motion,obj.handles.ah_abrdf});
            set(obj.handles.figure_abrdf,'WindowKeyPressFcn',{@obj.callback_key_press,obj.handles.ah_abrdf});
        end
        obj.callback_motion([], [], obj.handles.ah_abrdf);
    elseif src == obj.handles.ih_texture
        % mouse button down inside texture view
        if obj.handles.uix_boxpanel_texture.Docked
            set(obj.handles.figure, 'WindowButtonMotionFcn', {@obj.callback_motion, obj.handles.ah_texture});
            set(obj.handles.figure, 'WindowKeyPressFcn', {@obj.callback_key_press, obj.handles.ah_texture});
        else
            set(obj.handles.figure_texture, 'WindowButtonMotionFcn', {@obj.callback_motion, obj.handles.ah_texture});
            set(obj.handles.figure_texture, 'WindowKeyPressFcn', {@obj.callback_key_press, obj.handles.ah_texture});
        end
        pos = get(obj.handles.ah_texture, 'CurrentPoint');
        pos = round(pos(1, 1 : 2));
        if strcmpi(obj.sel_type, 'alt')
            % right button down -> start moving texture
            obj.prev_x = max(1, min(obj.width, pos(1)));
            obj.prev_y = max(1, min(obj.height, pos(2)));
        elseif strcmpi(obj.sel_type, 'extend')
            % middle button down -> start selecting roi
            if ~obj.show_only_roi
                obj.roi(1, 1) = min(obj.width, max(1, pos(1)));
                obj.roi(2, 1) = min(obj.height, max(1, pos(2)));
            end
        else
            if ~isempty(obj.roi) && ~obj.show_only_roi
                % start moving roi
                obj.prev_x = max(1, min(obj.width, pos(1)));
                obj.prev_y = max(1, min(obj.height, pos(2)));
            end
        end
        obj.callback_motion([],[],obj.handles.ah_texture);
    end
end
