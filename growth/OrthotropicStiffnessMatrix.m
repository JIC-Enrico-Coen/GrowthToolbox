function [D,C,K] = OrthotropicStiffnessMatrix( a1, a2, a3, b1, b2, b3, c1, c2, c3 )
%D = OrthotropicStiffnessMatrix( e1, e2, e3, nu )
%
%   Estimate a plausible axis-aligned orthotropic stiffness matrix, given
%   these Young's moduli and a single Poisson's ratio.
%
%D = OrthotropicStiffnessMatrix( a1, a2, a3, b1, b2, b3, c1, c2, c3 )
%   This just arranges the nine parameters into an axis-aligned orthotropic
%   stiffness matrix.
%
%   a1, a2, a3 are the diagonal elements of the top left 3x3.
%
%   b1, b2, b3 are the off-diagonal elements of the top left 3x3, where b_i
%   is in position (j,k) and (k,j).
%
%   c1, c2, c3 are the diagonal elements of the bottom right 3x3, which is
%   elsewhere zero.
%
%	The top right and bottom left quadrants are zero.
%
%   The result is a symmetric matrix. If the arguments are physically
%   possible then it is positive definite.


    if nargin==9
        D = [ a1 b3 b2 0  0  0;
              b3 a2 b1 0  0  0;
              b2 b1 a3 0  0  0;
              0  0  0  c1 0  0;
              0  0  0  0  c2 0;
              0  0  0  0  0  c3 ];
    elseif (nargin==4) || (nargin==5)
        % The arguments are the three Young's moduli, a single Poisson's
        % ratio, and an option to specify whether the p.r.s relating to the
        % normal direction should be set to 0: true (the default) means
        % non-zero, false means zero.
        if nargin==4
            pr_normal = true;
        else
            pr_normal = b2;
        end
        e1 = a1;
        e2 = a2;
        e3 = a3;
        nu = b1;
        
        % These are the equivalent bulk moduli for each Young's modulus.
        k1 = e1/(3*(1-2*nu));
        k2 = e2/(3*(1-2*nu));
        k3 = e3/(3*(1-2*nu));
        K = [ k1, k2, k3 ];
        
        % Six Poisson's ratios invented from a single one.
        if pr_normal
            nu12 = 2*e1*nu/(e1+e2);
            nu21 = 2*e2*nu/(e1+e2);
            nu23 = 2*e2*nu/(e2+e3);
            nu32 = 2*e3*nu/(e2+e3);
            nu31 = 2*e3*nu/(e3+e1);
            nu13 = 2*e1*nu/(e3+e1);
        else
            nu12 = 2*e1*nu/(e1+e2);
            nu21 = 2*e2*nu/(e1+e2);
            nu23 = 0;
            nu32 = 0;
            nu31 = 0;
            nu13 = 0;
        end
        
        % Shear moduli invented from an intuitive generalisation of the
        % isotropic formula g = e/(2(1+nu)). We replace the isotropic
        % Young's modulus e by the harmonic mean of the two relevant
        % orthotropic Young's moduli. This has the property of being small
        % when either of the moduli is small, and equal to them if they are
        % equal.
        g1 =  e2 * e3 / ((e2 + e3)*(1+nu));
        g2 =  e3 * e1 / ((e3 + e1)*(1+nu));
        g3 =  e1 * e2 / ((e1 + e2)*(1+nu));
        
        % This formula for the stiffness matrix comes from Claude. I have
        % checked the notation only for consistency, and that when
        % e1==e2==e3 it gives the correct isotropic tensor.
        Delta = 1 - nu12*nu21 - nu23*nu32 - nu13*nu31 - 2*nu12*nu23*nu31;
        C11 = e1*(1-nu23*nu32)/Delta;
        C22 = e2*(1-nu31*nu13)/Delta;
        C33 = e3*(1-nu12*nu21)/Delta;
        C12 = e1*(nu21 + nu31*nu23)/Delta;
        C21 = e2*(nu12 + nu13*nu32)/Delta;
        C13 = e1*(nu31 + nu21*nu32)/Delta;
        C31 = e3*(nu13 + nu12*nu23)/Delta;
        C23 = e2*(nu32 + nu12*nu31)/Delta;
        C32 = e3*(nu23 + nu21*nu13)/Delta;
        
        Ca = [ C11, C12, C13;
               C21, C22, C23;
               C31, C32, C33 ];
        C = [ Ca, zeros(3);
              zeros(3), diag( [ g1, g2, g3 ] ) ];
        
        % This formula for the compliance matrix comes from Claude. I have
        % checked the notation for consistency, and checked that it is the
        % inverse of C up to rounding error.
        S11 = 1/e1;
        S22 = 1/e2;
        S33 = 1/e3;
        S44 = 1/g1;
        S55 = 1/g2;
        S66 = 1/g3;
        S12 = -nu12/e1;
        S21 = -nu21/e2;
        S23 = -nu23/e2;
        S32 = -nu32/e3;
        S31 = -nu31/e3;
        S13 = -nu13/e1;
        Sa = [ S11 S12 S13;
               S21 S22 S23;
               S31 S32 S33 ];
        S = [ Sa, zeros(3);
              zeros(3), diag( [ S44, S55, S66 ] ) ];
        
        D = S;
        
        % D should be the inverse of C, which it is up to rounding error.
    end
end
