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
% Create image objects inside the texture and ABRDF axes.
function obj = ui_init_axes(obj)
    texture = zeros(obj.height, obj.width, obj.num_channels, 'single');
    obj.handles.ih_texture = image(texture, 'Parent', obj.handles.ah_texture);
    set(obj.handles.ah_texture, 'XTick', [], 'YTick', [], 'PlotBoxAspectRatio', [1, 1, 1]);
    set(get(obj.handles.ah_texture, 'XLabel'), 'String', 'x');
    set(get(obj.handles.ah_texture, 'YLabel'), 'String', 'y');
    hold(obj.handles.ah_texture, 'on');
    abrdf = obj.btfs{obj.b}.decode_abrdf(obj.x, obj.y);
    obj.handles.ih_abrdf = image(obj.tonemap(abrdf), 'Parent', obj.handles.ah_abrdf);
    set(obj.handles.ah_abrdf,'XTick',[], 'YTick',[], 'PlotBoxAspectRatio', [1, 1, 1]);
    set(get(obj.handles.ah_abrdf, 'XLabel'), 'String', '\omega_{V}');
    set(get(obj.handles.ah_abrdf, 'YLabel'), 'String', '\omega_{L}');
    hold(obj.handles.ah_abrdf, 'on');
    obj.handles.annot_texture = {};
    obj.handles.annot_abrdf = {};
    obj.handles.roi = [];
end
