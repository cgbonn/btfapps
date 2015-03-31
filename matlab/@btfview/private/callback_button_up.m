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
% React to released mouse button.
function obj = callback_button_up(obj, src, evnt) %#ok<INUSD>
    % mouse button released
    if strcmp(obj.sel_type, 'extend')
        % middle button released -> ROI selection finished
        if obj.roi(1, 1) > obj.roi(1, 2)
            obj.roi(1, :) = obj.roi(1, [2, 1]);
        end
        if obj.roi(2, 1) > obj.roi(2, 2)
            obj.roi(2, :) = obj.roi(2, [2, 1]);
        end
        obj.roi_sanity_checks();
    end
    obj.sel_type = '';
    % remove motion callback so it isn't triggered unnecessarily
    set(obj.handles.figure, 'WindowButtonMotionFcn', '');
    if isa(obj.handles.figure_abrdf, 'matlab.ui.Figure') && obj.handles.figure_abrdf.isvalid
        set(obj.handles.figure_abrdf, 'WindowButtonMotionFcn', '');
    end
    if isa(obj.handles.figure_texture, 'matlab.ui.Figure') && obj.handles.figure_texture.isvalid
        set(obj.handles.figure_texture, 'WindowButtonMotionFcn', '');
    end
end
