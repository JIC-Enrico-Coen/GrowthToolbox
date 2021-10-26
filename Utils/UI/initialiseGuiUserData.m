function initialiseGuiUserData( h, varargin )
%initialiseGuiUserData( h, varargin )
%   h is the guidata structure for a Matlab figure.
%   The arguments are alternately a value and a cell array of
%   field names of h.  The effect is to add a 'datainfo' field to the userdata
%   of those members of h, set to the given value.

    for i=1:2:length(varargin)
        value = varargin{i};
        fields = varargin{i+1};
        for j=1:length(fields)
            fn = fields{j};
            addUserData( h.(fn), 'datainfo', value );
        end
    end
end
