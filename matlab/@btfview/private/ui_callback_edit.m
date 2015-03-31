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
% React to edit box changes
function obj = ui_callback_edit(obj, src, evnt) %#ok<INUSD>
    val = get(src,'String');
    switch src
        case obj.handles.eh_buffer_mem
            value = str2double(val);
            % we only allow percentages
            if ~isnan(value) && 0 < value && value <= 100
                obj.buffer_mem = value / 100;
            end
            set(obj.handles.eh_buffer_mem, 'String', ...
                sprintf('%.1f', 100 * obj.buffer_mem));
        case obj.handles.eh_gamma
            tmp = obj.gamma;
            try %#ok<*TRYNC>
                tmp = str2double(val);
            end
            obj.gamma = tmp;
        case obj.handles.eh_offset
            tmp = obj.offset_color;
            try
                tmp = str2double(val);
            end
            obj.offset_color = tmp;
        case obj.handles.eh_scale
            tmp = obj.scale;
            try
                tmp = str2double(val);
            end
            obj.scale = tmp;
    end
    
    % region of interest has been edited
    if ismember(src, obj.handles.eh_roi)
        [r, c] = find(obj.handles.eh_roi == src);
        try
            val = round(str2double(val));
            
            if isempty(obj.roi)
                obj.roi = zeros(2, 2);
            end
            
            if c == 3
                % stride has been edited
                obj.roi_stride(r) = val;
            else
                % roi edited
                obj.roi(r, c) = val;
            end
            
            obj.roi_sanity_checks();
        catch
            if ~isempty(obj.roi)
                if c ~= 3
                    set(src, 'String', sprintf('%d', obj.roi(r, c)));
                else
                    set(src, 'String', sprintf('%d', obj.roi_stride(r)));
                end
            else
                set(src, 'String', '');
            end
        end
    end
    obj.show_texture();
    obj.show_abrdf();
end
