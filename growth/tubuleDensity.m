function [arealDensity,linearDensity,totalTubuleLength,meshArea] = tubuleDensity( m, sections )
%[arealDensity,linearDensity,totalTubuleLength,meshArea] = tubuleDensity( m )
%   Calculate the areal density of microtubules (total length * diameter / mesh area),
%   the linear density (total length/mesh area);
%   the total length of microtubules,
%   and the mesh area.
%
%[arealDensity,linearDensity,totalTubuleLength,meshArea] = tubuleDensity( m, sections )
%   SECTIONS must be an array mapping each element of M to a positive
%   integer. Consider this to be dividing M into sections consisting of all
%   the elements assigned the same number by SECTIONS.
%
%   The results are then the values corresponding to each of the sections.
%   They will all have the same shape as SECTIONS. To omit any parts of the
%   mesh, give them a section number of zero.
%
%   Densities for empty sections (i.e. indexes that are not assigned to any
%   element) are returned as zero.
%
%   For foliate meshes only.

    if isVolumetricMesh( m )
        arealDensity = 0;
        linearDensity = 0;
        totalTubuleLength = 0;
        meshArea = 0;
        return;
    end
    
    if nargin < 2
        sections = 1:getNumberOfFEs(m);
    end
    
%     if nargin < 2
%         % Each element is a section.
%         numFEs = getNumberOfFEs(m);
%         totalTubuleLength = zeros( 1, numFEs );
%         meshArea = m.cellareas;
%         for ti=1:length(m.tubules.tracks)
%             s = m.tubules.tracks(ti);
%             if ~isempty( s.segmentlengths )
%                 scis = s.segcellindex(1:length(s.segmentlengths));
%                 totalTubuleLength( scis ) = totalTubuleLength( scis ) + s.segmentlengths;
%             end
%         end
%         totalTubuleLength = totalTubuleLength';
%         linearDensity = totalTubuleLength./meshArea;
%         linearDensity( ~isfinite(linearDensity) ) = 0;
%         arealDensity = linearDensity * m.tubules.tubuleparams.radius * 2;
%     else
    if numel(sections)==1
        % The whole mesh is a single section, so we only want the aggregate
        % values.
        totalTubuleLength = sum([m.tubules.tracks.segmentlengths]);
        meshArea = sum(m.cellareas);
        linearDensity = totalTubuleLength/meshArea;
        arealDensity = linearDensity * m.tubules.tubuleparams.radius * 2;
    else
        numsections = max(sections);
        totalTubuleLength = zeros( 1, numsections );
        meshArea = zeros( 1, numsections );
        for ti=1:length(m.tubules.tracks)
            s = m.tubules.tracks(ti);
            numsegments = length(s.segmentlengths);
            fes = s.segcellindex; % (1:(numsegments-1));
            for segi=1:numsegments
                fe = fes(segi);
                fesect = sections(fe);
                if fesect ~= 0
                    totalTubuleLength( fesect ) = totalTubuleLength( fesect ) + s.segmentlengths(segi);
                end
            end
        end
        for secti=1:numsections
            meshArea(secti) =  sum( m.cellareas( sections==secti ) );
        end
        linearDensity = totalTubuleLength./meshArea;
        linearDensity(isnan(linearDensity)) = 0;
        arealDensity = linearDensity * m.tubules.tubuleparams.radius * 2;
    end
end
