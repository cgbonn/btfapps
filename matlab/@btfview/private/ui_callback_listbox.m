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
% React to list box selection changes.
function obj = ui_callback_listbox(obj, src, evnt) %#ok<INUSD>
    % BTF selection list
    val = get(src, 'Value');
    switch src
        case obj.handles.lh_btfs
            obj.b = val;
            if obj.btfs{obj.b}.is_bdi()
                obj.handles.uix_disp_bdi_bp.Visible = 'on';
            else
                obj.handles.uix_disp_bdi_bp.Visible = 'off';
            end
            obj.update_btf();
            obj.show_abrdf();
            obj.show_texture();
            obj.show_spectrum();
    end
end
