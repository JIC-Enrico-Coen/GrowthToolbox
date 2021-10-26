function varargout = numsDlg(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @numsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @numsDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
%if nargin && ischar(varargin{1})
%    gui_State.gui_Callback = str2func(varargin{1});
%end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before numsDlg is made visible.
function numsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for numsDlg
    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    % Insert default values.
    if ~isempty(varargin)
        for index = 1:2:(length(varargin)-1),
            if nargin-3==index, break, end
            switch lower(varargin{index})
              case 'title'
                set(hObject, 'Name', varargin{index+1});
              case 'errtext'
                set(handles.errText, 'String', varargin{index+1});
              case 'numstext'
                set(handles.numsText, 'String', varargin{index+1});
            end
        end
    end
    
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

    centreDialog(hObject);
    
    % Make the GUI modal
    uicontrol(handles.numsText);
    set(handles.numsFigure,'WindowStyle','modal');
    uicontrol(handles.numsText); % Both calls of uicontrol seem to be
                                 % necessary to make handles.numsText get
                                 % the focus.

    % UIWAIT makes numsDlg wait for user response (see UIRESUME)
    uiwait(handles.numsFigure);
end


% --- Outputs from this function are returned to the command line.
function varargout = numsDlg_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

    % The figure can be deleted now.
    delete(hObject);
end
