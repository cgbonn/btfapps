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
% React to UIX panel minimize / restore button clicks.
function obj = uix_callback_minimize(obj, src, evnt) %#ok<INUSD>
    % angular sampling can be minimized
    src = get(src, 'Parent');
    if src.Docked
        vbox = get(src, 'Parent');
        index = find(vbox.Contents == src);
        heights = get(vbox, 'Heights');
        src.Minimized = ~src.Minimized;
        if src.Minimized
            heights(index) = 20;
        else
            heights(index) = -1;
        end
        set(vbox, 'Heights', heights);
    end
end
