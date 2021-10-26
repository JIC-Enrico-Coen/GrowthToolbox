function ipos = handleInteriorSize( h )
    switch get( h, 'Type' )
        case { 'uipanel', 'figure' }
            % This is a bit of a hack. We need to discover the size of the
            % interior of this GUI element, which is the exterior size
            % minus the thicknesses of the borders.  However, there is no
            % Matlab call that can tell us this.  Instead, since at this
            % point we do not know the size of the element, we (1) resize
            % it to make it big enough to have an interior, (2) create a
            % uipanel within it, which defaults to taking up the full
            % interior area, (3) measuring its size, (4) deleting it,
            % (5) restoring the original size, and (6) adjusting the
            % measure of interior size to correct for the change in size.
            
            % When restoring the original size, we first have to ensure
            % that the original size is positive.  Since we obtained the
            % original size from the handle itself, one might expect it to
            % be valid, but this is not always the case.  Sometimes Matlab
            % will create a panel of zero size, but it will not accept
            % setting the size to zero.
            
            % Some of the complication of this became necessary with Matlab
            % R2013a.  Because the figure or uipanel at this point has been
            % created, but has not been given any contents, it has obtained
            % the default exterior size, which is 1 by 1 (sometimes 0 by
            % 0).  This gives it a theoretical interior size which is
            % negative.  R2012b and earlier were happy to return
            % a negative size for the object we create inside it, but
            % R2013a and later force the size to be positive.  This throws
            % off our later calculations.
            
            % It might help (and at this point I believe would make for
            % conceptually clearer code) to not carry out this calculation
            % until all of the inner GUI elements have been processed.
            % Then we would have a sensible minimum size for the element.
            % However, it would not avoid the necessity to measure its
            % interior size by creating a panel within it, because there is
            % no other way to measure it.  And I am not sure that creating
            % a panel while there are already other GUI elements present as
            % children will still size the panel to take up the entire
            % interior space.
            oldpos = get( h, 'Position' );  % Get the old size.
            oldpos([3 4]) = max( oldpos([3 4]), 1 ); % Force the size to be positive.
            tempsize = oldpos([3 4]) + [50 50];  % The first element must be at least the
                % combined thickness of the vertical borders, plus 1.  The
                % second must be at least the thickness of the lower border
                % plus the font size of the title, if any, otherwise the
                % combined thickness of the lower and upper borders; plus 1.
            set( h, 'Position', [ oldpos([1 2]), tempsize ] );  % Set the new size.
            ignore = get( h, 'Position' );  % I find that the setting of
                % Position doesn't take unless I read it back.
            hh = uipanel( 'Parent', h, 'Units', 'pixels', 'Visible', 'off' );
            ipos = get( hh, 'Position' );  % Determine the exterior size of hh = the interior size of h.
            ipos([3 4]) = ipos([3 4]) - tempsize + oldpos([3 4]); % Correct for the adjustment to the size of h.
            delete(hh);
            set( h, 'Position', oldpos );  % Restore the old size.
            ignore = get( h, 'Position' );  % This one is just superstition.
                % The code seems to work without it.  But that might be
                % because I happen to read the position at some later point
                % in the code.  In which case this line is needed in case I
                % should happen not to access the position later.
        otherwise
            p = get( h, 'Position' );
            ipos = p;
    end
end
