function [mc,mcA,mcB,pervertex] = meshColors( m, data )
    if nargin < 2
        if isempty(m.plotdata)
            mc = [];
            mcA = [];
            mcB = [];
            pervertex = true;
        else
            [data,dataA,dataB] = getplotdata( m );
            mc = convertDataToColor( m, data );
            mcA = convertDataToColor( m, dataA );
            mcB = convertDataToColor( m, dataB );
            pervertex = ~isfield( m.plotdata, 'pervertex' ) || m.plotdata.pervertex;
        end
    elseif size(data,2)==1
        mc = convertDataToColor( m, data );
        mcA = [];
        mcB = [];
        pervertex = size(data,1)==getNumberOfVertexes( m );
    end
end
    
function [d,dA,dB] = getplotdata( m )
    d = getplotdata1( m, '' );
    if isempty( d )
        dA = getplotdata1( m, 'A' );
        dB = getplotdata1( m, 'B' );
    else
        dA = [];
        dB = [];
    end
end
    
function d = getplotdata1( m, suffix )
    fn = ['value' suffix];
    if isfield(m.plotdata,fn) && ~isempty(m.plotdata.(fn))
        d = m.plotdata.(fn);
    else
        d = [];
    end
end

function c = convertDataToColor( m, d )
    if isempty(d)
        c = [];
    elseif size(d,2)==1
        if isfield( m.plotdata, 'cmap' ) && ~isempty( m.plotdata.cmap )
            cmap = m.plotdata.cmap;
        elseif ~isempty( m.plotdefaults.cmap )
            cmap = m.plotdefaults.cmap;
        else
            cmap = [];
        end
        if isempty(cmap)
            c = [];
        else
            c = interpolateArray( d, ...
                                  cmap, ...
                                  m.plotdefaults.crange );
        end
    else
        c = d;
    end
end

% function mc = getcolors( suffix )
%     fn = ['value' suffix];
%     if isfield(m.plotdata,fn) && ~isempty(m.plotdata.(fn))
%         mc = m.plotdata.(fn);
%         if size(mc,2)==1
%             if isfield( m.plotdata, 'cmap' ) && ~isempty( m.plotdata.cmap )
%                 cmap = m.plotdata.cmap;
%             elseif ~isempty( m.plotdefaults.cmap )
%                 cmap = m.plotdefaults.cmap;
%             else
%                 cmap = [];
%             end
%             if isempty(cmap)
%                 mc = [];
%             else
%                 mc = interpolateArray( mc, ...
%                                        cmap, ...
%                                        m.plotdefaults.crange );
%             end
%         end
%     else
%         mc = [];
%     end
% end
