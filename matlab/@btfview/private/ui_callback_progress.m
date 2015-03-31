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
% This method updates a status text and optionally a progress bar in the GUI.
function ui_callback_progress(obj, value, str)
    % update progress bar & status text
    if exist('value', 'var')
        set(obj.handles.uix_vbox_global, 'Heights', [-1, 30, 115]);
        if ~exist('str', 'var')
            str = '';
        end
        
        if obj.fancy_progress
            set(obj.handles.java_progress_bar, 'Value' , 100 * value);
            set(obj.handles.th_status, 'String', str);
        else
            set(obj.handles.th_status, 'String', sprintf('%03.2f%% %s', 100 * value, str));
        end
    else
        set(obj.handles.th_status, 'String', '');
        set(obj.handles.uix_vbox_global, 'Heights', [-1, 0, 115]);
    end
    drawnow;
end
