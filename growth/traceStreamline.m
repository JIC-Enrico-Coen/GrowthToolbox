function m = traceStreamline( m, field, ci )
%m = traceStreamline( m, ci )
%   Start a streamline from the centre of the finite element ci. Continue
%   it in both directions until it either hits the edge of the mesh, is
%   reflected back into the FE it just came from, or hits a cell with no
%   gradient.
%
%   OBSOLETE, WILL NOT WORK.

    % Represent the streamline being built in one direction by a list of
    % FEs, and for each FE, the bcs of the ends within the FE.
    
    % Need to get the polarisation gradient in barycentric coords.  This is
    % not done anywhere at present.  Do it here and don't retain it?
    
    if m.hasstreamline(ci)
        return;
    end
    m.hasstreamline(ci) = true;
    currentcell = ci;
    bc = [1 1 1]/3;
    pol_mgen = polariserIndex( m );
    v = m.morphogens(:,pol_mgen);

    vxsi = m.tricellvxs(currentcell,:);
    vxs = m.nodes(vxsi,:);
    [gradpos,gradneg] = projectstreamline( v(vxsi), bc, vxs );
    
    [poscells,posbcstart,posbcend] = onewaystreamline( currentcell, gradpos, true );
    [negcells,negbcstart,negbcend] = onewaystreamline( currentcell, gradneg, false );
    streamcells = [ negcells(end:-1:1), currentcell, poscells ];
    streambcstart = [ negbcend(end:-1:1,:); posbcstart ];
    streambcend = [ negbcstart(end:-1:1,:); posbcend ];
    for i=1:length(streamcells)
        ci = streamcells(i);
        m.streambcstart(ci,:) = streambcstart(i,:);
        m.streambcend(ci,:) = streambcend(i,:);
    end
  % fprintf( 1, 'num(streamcells) %d\n', length(streamcells) );
  % fprintf( 1, 'num(streambcstart) %d\n', size(streambcstart,1) );
  % fprintf( 1, 'num(streambcend) %d\n', size(streambcend,1) );
    plotstreamline( m, streamcells, streambcstart, streambcend );
    return;

    function [cells,bcstart,bcend] = onewaystreamline( currentcell, grad, positive )
        bcstart = [];
        bcend = grad;
        cells = [];
        while ~isempty(grad)
            [cj,bc] = transferEdgeBC( m, currentcell, grad );
            if cj==0
                break;
            end
            if m.hasstreamline(cj)
                break;
            end
            m.hasstreamline(cj) = true;
            currentcell = cj;
            vxsi = m.tricellvxs(currentcell,:);
            vxs = m.nodes(vxsi,:);
            grad = projectstreamline( v(vxsi), bc, vxs, positive );
            if ~isempty(grad)
                bcstart(end+1,:) = bc;
                cells(end+1) = cj;
                bcend(end+1,:) = grad;
            end
        end
    end
end


function plotstreamline( m, cis, bcstart, bcend )
    numcells = length(cis);
    vxsstart = zeros(numcells+1,3);
  % vxsend = zeros(numcells,3);
    for i=1:numcells
        vxsstart(i,:) = bcstart(i,:) * m.nodes( m.tricellvxs(cis(i),:), : );
      % vxsend(i,:) = bcend(i,:) * m.nodes( m.tricellvxs(cis(i),:), : );
    end
    vxsstart( numcells+1, : ) = bcend(numcells,:) * m.nodes( m.tricellvxs(cis(numcells),:), : );
  % vxsend(:,3) = 1;
    plotpts( gca, vxsstart,'-b', 'LineWidth', 2 );
    drawnow
  % plotpts( gca, vxsend,'o-r' );
end
