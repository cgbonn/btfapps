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
% Set main figure and axes callbacks.
function obj = ui_set_callbacks(obj)
    set(obj.handles.figure, 'WindowKeyPressFcn', {@obj.callback_key_press, obj.handles.ah_texture});
    set(obj.handles.figure, 'WindowKeyReleaseFcn', @obj.callback_key_release);
    set(obj.handles.figure, 'WindowScrollWheelFcn', @obj.callback_scroll_wheel);
    set(obj.handles.ih_texture, 'ButtonDownFcn', @obj.callback_button_down);
    set(obj.handles.ih_abrdf, 'ButtonDownFcn', @obj.callback_button_down);
    set(obj.handles.figure, 'WindowButtonUpFcn', @obj.callback_button_up);
    set(obj.handles.figure, 'CloseRequestFcn', @obj.callback_exit);
end
