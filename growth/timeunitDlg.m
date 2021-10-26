function varargout = timeunitDlg(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @timeunitDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @timeunitDlg_OutputFcn, ...
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


% --- Executes just before timeunitDlg is made visible.
function timeunitDlg_OpeningFcn(hObject, eventdata, handles, varargin)
    foreColor = [0.9 1 0.9];
    backColor = [0.4 0.8 0.4];
    setGUIColors( hObject, backColor, foreColor )

    % Choose default command line output for timeunitDlg
    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    % Insert default values.
    if ~isempty(varargin)
        for index = 1:2:(length(varargin)-1),
            if nargin-3==index, break, end
            switch lower(varargin{index})
              case 'starttime'
                set(handles.starttimeText, 'String', ...
                    sprintf( '%f', varargin{index+1} ));
              case 'timeunitname'
                set(handles.timeunitText, 'String', varargin{index+1});
            end
        end
    end

    centreDialog(hObject);
    
    % Make the GUI modal
    uicontrol(handles.timeunitText);
    set(handles.figure1,'WindowStyle','modal');
    uicontrol(handles.timeunitText);

    % UIWAIT makes timeunitDlg wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = timeunitDlg_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

    % The figure can be deleted now.
    delete(hObject);
end
