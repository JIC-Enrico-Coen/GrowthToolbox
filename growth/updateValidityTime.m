function m = updateValidityTime( m, minPreviousValidTime )
%m = updateValidityTime( m, minPreviousValidTime )
%   m is assumed to have changed in some way since the time
%   minPreviousValidTime.  If the validity time was before
%   minPreviousValidTime, it is not changed, otherwise it is set to the
%   current time.
%
%   The idea is that if the mesh was at a valid time before the change,
%   then it is valid at the current time but not any later time.  However,
%   if the mesh was already invalid it remains so.
%
%   If this results in reducing the validity time, the lineage data for
%   later times is invalidated.

    if m.globalProps.validitytime >= minPreviousValidTime
        needLineageInvalidation = m.globalProps.validitytime > m.globalDynamicProps.currenttime;
        m.globalProps.validitytime = m.globalDynamicProps.currenttime;
        if needLineageInvalidation
            % Invalidate later lineage history.
            m = invalidateLineage( m, m.globalProps.validitytime );
        end
    end
end

