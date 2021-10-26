function apg = avpolgrad( m, ci, vx, sparsedistance, data )
%apg = avpolgrad( m, ci, vx, sparsedistance, data )
%   Calculate the average polarisation gradient over all of the finite
%   elements, all of whose vertexes are within a distance sparsedistance of
%   vx.
%
%   If DATA is specified, it will be used instead of m.gradpolgrowth.

%   Updated:twosidedpolarisation.

    if nargin < 6
        data = m.gradpolgrowth;
    end

    spdsq = sparsedistance*sparsedistance;
    cis = ci;
    cisi = 1;
    seenci = false( 1, size(m.tricellvxs,1) );
    totalgrad = data( ci, :, : ) * m.cellareas(ci);
    totalarea = m.cellareas(ci);
    while cisi <= length(cis)
        ci1 = cis(cisi);
        cisi = cisi+1;
        seenci(ci1) = true;
        % Find the neighbours of the current element.
        nbci = nbvcells( m, ci1 );
        % Ignore neighbours already processed.
        nbci = nbci( ~seenci(nbci) );
        for ci2=nbci
            centre = sum( m.nodes( m.tricellvxs(ci2,:), : ), 1 )/3;
            % If the neighbour has its centre close enough, update total
            % gradient and total area.
            if sum((centre-vx).^2) < spdsq
                area = m.cellareas(ci1);
                grad = data(ci2,:,:);
                totalgrad = totalgrad + grad*area;
                totalarea = totalarea + area;
            end
        end
    end
    apg = totalgrad/totalarea;
end

