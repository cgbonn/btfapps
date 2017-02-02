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
% React to mouse motion events.
function obj = callback_motion(obj, src, evnt, ah) %#ok<INUSL>
    % mouse motion
    pos = get(ah, 'CurrentPoint');
    pos = round(pos(1, 1 : 2));
    if ah == obj.handles.ah_texture
        % motion inside texture view
        switch obj.sel_type
            case 'normal' % dragging with left button -> select ABRDF
                if obj.wrap_around_texture || obj.offset_x || obj.offset_y
                    obj.x = mod(pos(1) - obj.offset_x - 1, obj.width) + 1;
                    obj.y = mod(pos(2) - obj.offset_y - 1, obj.height) + 1;
                else
                    obj.x = min(obj.width, max(1, pos(1)));
                    obj.y = min(obj.height, max(1, pos(2)));
                end
                if ~isempty(obj.roi) && ~obj.show_only_roi
                    % if mouse is left dragged inside roi, move roi
                    if obj.roi(1,1) <= obj.x && obj.x <= obj.roi(1,2) && ...
                            obj.roi(2,1) <= obj.y && obj.y <= obj.roi(2,2)
                        delta_x = obj.x - obj.prev_x;
                        delta_y = obj.y - obj.prev_y;
                        obj.roi(1, :) = obj.roi(1, :) + delta_x;
                        obj.roi(2, :) = obj.roi(2, :) + delta_y;
                        obj.roi_sanity_checks();
                        obj.prev_x = obj.x;
                        obj.prev_y = obj.y;
                    end
                end
            case 'alt'
                % dragging with right button -> move texture
                tmp_x = max(1,min(obj.width,pos(1)));
                tmp_y = max(1,min(obj.height,pos(2)));
                delta_x = (tmp_x - obj.prev_x);
                delta_y = (tmp_y - obj.prev_y);
                obj.offset_x = obj.offset_x + delta_x;
                obj.offset_y = obj.offset_y + delta_y;
                obj.prev_x = tmp_x;
                obj.prev_y = tmp_y;
                if ~isempty(obj.roi)&& ~obj.show_only_roi
                    % right dragging inside ROI -> move ROI
                    obj.roi(1, :) = obj.roi(1, :) + delta_x;
                    obj.roi(2, :) = obj.roi(2, :) + delta_y;
                    obj.roi_sanity_checks();
                end
            case 'extend'
                % dragging with middle button -> select roi
                if ~obj.show_only_roi
                    obj.roi(1, 2) = min(obj.width, max(1, pos(1)));
                    obj.roi(2, 2) = min(obj.height, max(1, pos(2)));
                end
                % update ROI edit boxes
                for ii = 1 : 4
                    set(obj.handles.eh_roi(ii), 'String', sprintf('%d', obj.roi(ii)));
                end
                if isempty(obj.roi_stride)
                    obj.roi_stride = ones(2, 1);
                end
                set(obj.handles.eh_roi(1, 3), 'String', obj.roi_stride(1));
                set(obj.handles.eh_roi(2, 3), 'String', obj.roi_stride(2));
        end
    elseif ah == obj.handles.ah_abrdf
        % motion inside ABRDF view -> update texture
        obj.l = max(1,min(obj.num_lights,round(pos(2))));
        obj.v = max(1,min(obj.num_views,round(pos(1))));
    end
    obj.show_texture();
    obj.show_abrdf();
    obj.show_spectrum();
end
