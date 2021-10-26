function varargout = distunitDlg(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @distunitDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @distunitDlg_OutputFcn, ...
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


% --- Executes just before distunitDlg is made visible.
function distunitDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

    % Choose default command line output for distunitDlg
    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    % Insert default values.
    if ~isempty(varargin)
        for index = 1:2:(length(varargin)-1),
            if nargin-3==index, break, end
            switch lower(varargin{index})
              case 'distunitname'
                set(handles.distunitText, 'String', varargin{index+1});
              case 'scaleunit'
                set(handles.scaleunitText, 'String', num2string( varargin{index+1} ) );
            end
        end
    end

    centreDialog(hObject);
    
    % Make the GUI modal
    uicontrol(handles.distunitText);
    set(handles.figure1,'WindowStyle','modal');
    uicontrol(handles.distunitText);

    % UIWAIT makes distunitDlg wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = distunitDlg_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

    % The figure can be deleted now.
    delete(hObject);
end


