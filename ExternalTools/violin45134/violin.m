%__________________________________________________________________________
% violin.m - Simple violin plot using matlab default kernel density estimation
% Last update: 10/2015
%__________________________________________________________________________
% This function creates violin plots based on kernel density estimation
% using ksdensity with default settings. Please be careful when comparing pdfs
% estimated with different bandwidth!
%
% Differently to other boxplot functions, you may specify the x-position.
% This is usefule when overlaying with other data / plots.
%__________________________________________________________________________
%
% Please cite this function as:
% Hoffmann H, 2015: violin.m - Simple violin plot using matlab default kernel
% density estimation. INRES (University of Bonn), Katzenburgweg 5, 53115 Germany.
% hhoffmann@uni-bonn.de
%
%__________________________________________________________________________
%
% INPUT
%
% Y:     Data to be plotted, being either
%        a) n x m matrix. A 'violin' is plotted for each column m, OR
%        b) 1 x m Cellarry with elements being numerical colums of nx1 length.
%
% varargin:
% xlabel:    xlabel. Set either [] or in the form {'txt1','txt2','txt3',...}
% facecolor: FaceColor. (default [1 0.5 0]); Specify abbrev. or m x 3 matrix (e.g. [1 0 0])
% edgecolor: LineColor. (default 'k'); Specify abbrev. (e.g. 'k' for black); set either [],'' or 'none' if the mean should not be plotted
% facealpha: Alpha value (transparency). default: 0.5
% mc:        Color of the bars indicating the mean. (default 'k'); set either [],'' or 'none' if the mean should not be plotted
% medc:      Color of the bars indicating the median. (default 'r'); set either [],'' or 'none' if the mean should not be plotted
% bw:        Kernel bandwidth. (default []); prescribe if wanted as follows:
%            a) if bw is a single number, bw will be applied to all
%            columns or cells
%            b) if bw is an array of 1xm or mx1, bw(i) will be applied to cell or column (i).
%            c) if bw is empty (default []), the optimal bandwidth for
%            gaussian kernel is used (see Matlab documentation for
%            ksdensity()
%
% OUTPUT
%
% h:     figure handle
% L:     Legend handle
% MX:    Means of groups
% MED:   Medians of groups
% bw:    bandwidth of kernel
%__________________________________________________________________________
%
% Example1 (default):
% 
% disp('this example uses the statistical toolbox')
% Y=[rand(1000,1),gamrnd(1,2,1000,1),normrnd(10,2,1000,1),gamrnd(10,0.1,1000,1)];
% [h,L,MX,MED]=violin(Y);
% ylabel('\Delta [yesno^{-2}]','FontSize',14)
%
% %Example2 (specify facecolor, edgecolor, xlabel):
% 
% disp('this example uses the statistical toolbox')
% Y=[rand(1000,1),gamrnd(1,2,1000,1),normrnd(10,2,1000,1),gamrnd(10,0.1,1000,1)];
% violin(Y,'xlabel',{'a','b','c','d'},'facecolor',[1 1 0;0 1 0;.3 .3 .3;0 0.3 0.1],'edgecolor','b',...
% 'bw',0.3,...
% 'mc','k',...
% 'medc','r--')
% ylabel('\Delta [yesno^{-2}]','FontSize',14)
% 
% %Example3 (specify x axis location):
% 
% disp('this example uses the statistical toolbox')
% Y=[rand(1000,1),gamrnd(1,2,1000,1),normrnd(10,2,1000,1),gamrnd(10,0.1,1000,1)];
% violin(Y,'x',[-1 .7 3.4 8.8],'facecolor',[1 1 0;0 1 0;.3 .3 .3;0 0.3 0.1],'edgecolor','none',...
% 'bw',0.3,'mc','k','medc','r-.')
% axis([-2 10 -0.5 20])
% ylabel('\Delta [yesno^{-2}]','FontSize',14)
% 
% %Example4 (Give data as cells with different n):
% 
% disp('this example uses the statistical toolbox')
% 
% Y{:,1}=rand(10,1);
% Y{:,2}=rand(1000,1);
% violin(Y,'facecolor',[1 1 0;0 1 0;.3 .3 .3;0 0.3 0.1],'edgecolor','none','bw',0.1,'mc','k','medc','r-.')
% ylabel('\Delta [yesno^{-2}]','FontSize',14)

function[h,L,MX,MED,bw]=violin(Y,varargin)

%convert single columns to cells:
if iscell(Y)==0
    Y = num2cell(Y,1);
end

%get additional input parameters (varargin)
[s,ok] = safemakestruct( mfilename(), varargin );
plotmean = isfield(s, 'mc') && ~isempty(s.mc);
plotmedian = isfield(s, 'medc') && ~isempty(s.medc);
s = defaultfields( s, ...
    'xlabel', [], ...
    'facecolor', [1 0.5 0], ...
    'edgecolor', 'k', ...
    'facealpha', 0.5, ...
    'mc', 'k', ...
    'medc', 'r', ...
    'bw', [], ...
    'plotlegend', 1, ...
    'support', [], ...
    'x', [] );
if ~isfield( s, 'ParentFig' )
    if ~isfield( s, 'ParentAx' )
        [s.ParentFig,s.ParentAx] = getFigure();
    else
        s.ParentFig = ancestor( s.ParentAx, 'Figure' );
    end
elseif ~isfield( s, 'ParentAx' )
    [~,s.ParentAx] = getFigure( s.ParentFig );
end
set(0, 'CurrentFigure', s.ParentFig);
set(s.ParentFig, 'CurrentAxes', s.ParentAx);
xL = s.xlabel;
fc = s.facecolor;
lc = s.edgecolor;
alp = s.facealpha;
mc = s.mc;
medc = s.medc;
b = s.bw;
plotlegend = s.plotlegend;
x = s.x;
if ~isempty(b)
    if length(b)==1
        disp(['same bandwidth bw = ',num2str(b),' used for all cols'])
        b=repmat(b,size(Y,2),1);
    elseif length(b)~=size(Y,2)
        warning('length(b)~=size(Y,2)')
        error('please provide only one bandwidth or an array of b with same length as columns in the data set')
    end
end

if size(fc,1)==1
    fc=repmat(fc,size(Y,2),1);
end

%% Calculate the kernel density
if isempty( s.support )
    baseargs = {};
else
    baseargs = {'support',s.support};
end

weights = zeros( 1, size(Y,2) );
for yi=1:size(Y,2)
    if isempty(b)
        extraargs = baseargs;
    else
        extraargs = [ baseargs, {'bandwidth',b(yi)} ];
    end
    if isempty( Y{yi} )  % Added by RK 2024 Oct 04. If Y{yi} is empty, ksdensity will throw an error.
        f = NaN;
        u = NaN;
        bb = NaN;
    else
        [f, u, bb]=ksdensity(Y{yi},extraargs{:});
    end
    
%     f = f/max(f)*0.3; %normalize
    weights(yi) = sum(Y{yi},'omitnan');
    F(:,yi) = f;
    U(:,yi) = u;
    MED(:,yi) = median(Y{yi},'omitnan');
    MX(:,yi) = mean(Y{yi},'omitnan');
    bw(:,yi) = bb;
    
end

% Normalise while preserving proportions of multiple violins.
% weights = sum( F, 1, 'omitnan' );
weights1 = weights/max( weights );
weights = weights1;
Fmax = max( F, [], 1 );
F = F.*(0.3 * weights./Fmax);

%%
%-------------------------------------------------------------------------
% Put the figure automatically on a second monitor
% mp = get(0, 'MonitorPositions');
% set(gcf,'Color','w','Position',[mp(end,1)+50 mp(end,2)+50 800 600])
%-------------------------------------------------------------------------
%Check x-value options
if isempty(x)
    x = zeros(size(Y,2));
    setX = 0;
else
    setX = 1;
    if isempty(xL)==0
        disp('_________________________________________________________________')
        warning('Function is not designed for x-axis specification with string label')
        warning('when providing x, xlabel can be set later anyway')
        error('please provide either x or xlabel. not both.')
    end
end

%% Plot the violins
i=1;
for i=i:size(Y,2)
    if isempty(lc) == 1
        if setX == 0
            h(i)=fill( [F(:,i)+i;flipud(i-F(:,i))], [U(:,i);flipud(U(:,i))], fc(i,:), ...
                'FaceAlpha',alp,'EdgeColor','none','Parent',s.ParentAx);
        else
            h(i)=fill( [F(:,i)+x(i);flipud(x(i)-F(:,i))], [U(:,i);flipud(U(:,i))], fc(i,:), ...
                'FaceAlpha',alp,'EdgeColor','none','Parent',s.ParentAx);
        end
    else
        if setX == 0
            h(i)=fill( [F(:,i)+i;flipud(i-F(:,i))], [U(:,i);flipud(U(:,i))], fc(i,:), ...
                'FaceAlpha',alp,'EdgeColor',lc,'Parent',s.ParentAx);
        else
            h(i)=fill( [F(:,i)+x(i);flipud(x(i)-F(:,i))], [U(:,i);flipud(U(:,i))], fc(i,:), ...
                'FaceAlpha',alp,'EdgeColor',lc,'Parent',s.ParentAx);
        end
    end
    hold on
    if setX == 0
        if plotmean == 1
            p(1)=plot( [ interp1(U(:,i),F(:,i)+i,MX(:,i)), interp1(flipud(U(:,i)), flipud(i-F(:,i)), MX(:,i)) ], [MX(:,i) MX(:,i)],mc, ...
                'LineWidth',2,'Parent',s.ParentAx);
        end
        if plotmedian == 1
            p(2)=plot( [ interp1(U(:,i),F(:,i)+i,MED(:,i)), interp1(flipud(U(:,i)), flipud(i-F(:,i)), MED(:,i)) ], [MED(:,i) MED(:,i)],medc, ...
                'LineWidth',2,'Parent',s.ParentAx);
        end
    elseif setX == 1
        if plotmean == 1
            p(1)=plot( [ interp1(U(:,i),F(:,i)+i,MX(:,i))+x(i)-i, interp1(flipud(U(:,i)), flipud(i-F(:,i)), MX(:,i))+x(i)-i ], [MX(:,i) MX(:,i)],mc, ...
                'LineWidth',2,'Parent',s.ParentAx);
        end
        if plotmedian == 1
            p(2)=plot( [ interp1(U(:,i),F(:,i)+i,MED(:,i))+x(i)-i, interp1(flipud(U(:,i)), flipud(i-F(:,i)), MED(:,i))+x(i)-i ], [MED(:,i) MED(:,i)], ...
                medc,'LineWidth',2,'Parent',s.ParentAx);
        end
    end
end

%% Add legend if requested
if ((plotlegend==1) && (plotmean==1)) || ((plotlegend==1) && (plotmedian==1))
    
    if plotmean==1 && plotmedian==1
        L=legend([p(1) p(2)],'Mean','Median');
    elseif plotmean==0 && plotmedian==1
        L=legend(p(2),'Median');
    elseif plotmean==1 && plotmedian==0
        L=legend(p(1),'Mean');
    end
    
    set(L,'box','off','FontSize',14)
else
    L=[];
end

%% Set axis
if setX == 0
    axis([0.5 size(Y,2)+0.5, min(U(:)) max(U(:))]);
elseif setX == 1
    axis([min(x)-0.05*range(x) max(x)+0.05*range(x), min(U(:)) max(U(:))]);
end

%% Set x-labels
xL2={''};
i=1;
for i=1:size(xL,2)
    xL2=[xL2,xL{i},{''}];
end
set(s.ParentAx,'TickLength',[0 0],'FontSize',12)
box on

if isempty(xL)==0
    set(s.ParentAx,'XtickLabel',xL2)
end
%-------------------------------------------------------------------------
end %of function