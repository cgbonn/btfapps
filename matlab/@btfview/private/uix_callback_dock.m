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
function obj = uix_callback_dock(obj, src, evnt) %#ok<INUSD>
    if src == obj.handles.figure_abrdf
        src = obj.handles.uix_boxpanel_abrdf;
    elseif src == obj.handles.figure_sampling
        src = obj.handles.uix_boxpanel_sampling;
    elseif src == obj.handles.figure_texture
        src = obj.handles.uix_boxpanel_texture;
    else
        src = get(src, 'Parent');
    end
    
    if src == obj.handles.uix_boxpanel_abrdf
        new_parent = obj.handles.uix_vbox_upper_right;
        new_title = 'ABRDF';
    elseif src == obj.handles.uix_boxpanel_sampling
        new_parent = obj.handles.uix_vbox_upper_right;
        new_title = 'Angular sampling';
        if obj.handles.uix_boxpanel_sampling.Minimized
            obj.uix_callback_minimize(obj.handles.ah_sampling);
        end
    elseif src == obj.handles.uix_boxpanel_texture
        new_parent = obj.handles.uix_vbox_upper_left;
        new_title = 'Texture';
    end
    
    src.Docked = ~src.Docked;
    if src.Docked
        % put panel back into the layout
        new_fig = get(src, 'Parent');
        set(src, 'Parent', new_parent);
        delete(new_fig);
    else
        % take panel out of the layout
        pos = getpixelposition(src);
        new_fig = figure('Name', new_title, 'NumberTitle', 'off', ...
            'MenuBar', 'none', 'Toolbar', 'none', ...
            'CloseRequestFcn', @obj.callback_dock, ...
            'WindowButtonUpFcn', @obj.callback_button_up);
        fig_pos = get(new_fig, 'Position');
        set(new_fig, 'Position', [fig_pos(1,1:2), pos(1,3:4)]);
        set(src, 'Parent', new_fig, ...
            'Units', 'Normalized', ...
            'Position', [0 0 1 1]);
        if src == obj.handles.uix_boxpanel_abrdf
            obj.handles.figure_abrdf = new_fig;
        elseif src == obj.handles.uix_boxpanel_texture
            obj.handles.figure_texture = new_fig;
        else
            obj.handles.figure_sampling = new_fig;
        end
    end
end
