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
% React to pressed key.
function obj = callback_key_press(obj, src, evnt, ah) %#ok<INUSL>
    % key pressed
    switch evnt.Key
        case 'leftarrow'
            hor = -1;
            ver = 0;
        case 'rightarrow'
            hor = 1;
            ver = 0;
        case 'downarrow'
            hor = 0;
            ver = 1;
        case 'uparrow'
            hor = 0;
            ver = -1;
        case {'control', 'shift', 'alt'}
            obj.key_mod = evnt.Key;
        case 'a'
            obj.autoscale();
        case 'c'
            obj.crosshair = ~obj.crosshair;
        case 'g'
            obj.tonemapper.gamma = obj.default_gamma;
            set(obj.handles.eh_gamma, 'String', sprintf('%.2f', obj.tonemapper.gamma));
        case 'n'
            obj.normalize = ~obj.normalize;
        case 'o'
            obj.tonemapper.offset = obj.default_offset_color;
            set(obj.handles.eh_offset, 'String', sprintf('%.2f', obj.tonemapper.offset));
        case 's'
            obj.tonemapper.scale = obj.default_scale;
            set(obj.handles.eh_scale, 'String', sprintf('%.2f', obj.tonemapper.scale));
        case 'x'
            obj.offset_x = 0;
        case 'y'
            obj.offset_y = 0;
    end
    if exist('hor', 'var')
        if ah == obj.handles.ah_texture
            obj.x = mod(obj.x + hor - 1, obj.width) + 1;
            obj.y = mod(obj.y + ver - 1, obj.height) + 1;
        elseif ah == obj.handles.ah_abrdf
            obj.v = max(1, min(obj.num_views, obj.v + hor));
            obj.l = max(1, min(obj.num_lights, obj.l + ver));
        end
    end
    obj.show_texture();
    obj.show_abrdf();
    obj.show_spectrum();
    % sometimes this callback is lost...
    set(obj.handles.figure,'WindowKeyReleaseFcn',@obj.callback_key_release);
end
