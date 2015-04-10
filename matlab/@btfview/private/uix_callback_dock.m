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
% React to UIX panel dock / undock button clicks.
function obj = uix_callback_dock(obj, src, evnt, uixobj) %#ok<INUSL>
    if uixobj == obj.handles.uix_boxpanel_abrdf
        new_parent = obj.handles.uix_vbox_upper_right;
        new_title = 'ABRDF';
    elseif uixobj == obj.handles.uix_boxpanel_sampling
        new_parent = obj.handles.uix_vbox_upper_right;
        new_title = 'Angular sampling';
        if obj.handles.uix_boxpanel_sampling.IsMinimized
            obj.uix_callback_minimize(obj.handles.ah_sampling);
        end
    elseif uixobj == obj.handles.uix_boxpanel_texture
        new_parent = obj.handles.uix_vbox_upper_left;
        new_title = 'Texture';
    end
    
    uixobj.IsDocked = ~uixobj.IsDocked;
    if uixobj.IsDocked
        % put panel back into the layout
        new_fig = get(uixobj, 'Parent');
        set(uixobj, 'Parent', new_parent);
        delete(new_fig);
        new_fig = [];
    else
        % take panel out of the layout
        pos = getpixelposition(uixobj);
        new_fig = figure('Name', new_title, 'NumberTitle', 'off', ...
            'MenuBar', 'none', 'Toolbar', 'none', ...
            'CloseRequestFcn', {@obj.uix_callback_dock, uixobj}, ...
            'WindowButtonUpFcn', @obj.callback_button_up);
        fig_pos = get(new_fig, 'Position');
        set(new_fig, 'Position', [fig_pos(1,1:2), pos(1,3:4)]);
        set(uixobj, 'Parent', new_fig, ...
            'Units', 'Normalized', ...
            'Position', [0 0 1 1]);
    end
    
    % set / reset figure handles
    if uixobj == obj.handles.uix_boxpanel_abrdf
        obj.handles.figure_abrdf = new_fig;
    elseif uixobj == obj.handles.uix_boxpanel_texture
        obj.handles.figure_texture = new_fig;
    elseif uixobj == obj.handles.uix_boxpanel_sampling
        obj.handles.figure_sampling = new_fig;
    end
end
