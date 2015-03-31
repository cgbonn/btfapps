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
% Clean up all opened windows as soon as the main figure is closed.
function obj = callback_exit(obj, src, evnt) %#ok<INUSD>
    % clean up opened figures
    if src == obj.handles.figure
        if ~isempty(obj.handles.figure_sampling)
            delete(obj.handles.figure_sampling);
        end
        if isa(obj.handles.figure_abrdf, 'matlab.ui.Figure') && ...
                obj.handles.figure_abrdf.isvalid
            delete(obj.handles.figure_abrdf);
        end
        if isa(obj.handles.figure_texture, 'matlab.ui.Figure') && ...
                obj.handles.figure_texture.isvalid
            delete(obj.handles.figure_texture);
        end
        if isa(obj.handles.figure_sampling, 'matlab.ui.Figure') && ...
                obj.handles.figure_sampling.isvalid
            delete(obj.handles.figure_sampling);
        end
        delete(obj.handles.figure);
    end
end
end
