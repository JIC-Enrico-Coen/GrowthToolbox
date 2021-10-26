function setGFtboxHandles( handles )
%setGFtboxHandles( handles )
%   Install the handles into the GFtbox figure.

    guidata( handles.output, handles );
end