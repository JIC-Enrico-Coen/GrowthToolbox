function varargout = dialogOutputFcn(hObject, handles)
% Get the result of the dialog.
varargout{1} = handles.output;

% The figure can be deleted now.
delete(hObject);
end
