% *************************************************************************
% * Copyright 2017 University of Bonn
% *
% * authors:
% *  - Sebastian Merzbach <merzbach@cs.uni-bonn.de>
% *
% * last modification date: 2017-02-02
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
% Display buffer status of BDIs.
function ui_update_bdi_chunks(obj)
    if ~isfield(obj.handles, 'uix_bdi_bp')
        return;
    end
    
    [~, num_buf, num_tot] = ...
        obj.btfs{obj.b}.is_buffered();
    obj.handles.th_num_buffered.String = sprintf('chunks buffered: %d / %d (%3.2f%%)', ...
        num_buf, num_tot, 100 * num_buf / num_tot);
end
