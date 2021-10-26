function [s1]=ReconcileFields(s1,s2,verbose)
    %function [s1]=ReconcileFields(s1,s2)
    %
    %Recursively find all fields in s2 that do not exist in s1
    %then create them as empty fields in s1 
    %
    %to ensure two structures have the same fields
    %call the function twice, i.e.
    %s1=ReconcileFields(s1,s2); 
    %s2=ReconcileFields(s2,s1)
    %
    %J.Andrew Bangham, 2008
    if nargin<3
        verbose=false;
    end
    f1=fieldnames(s1);
    f2=fieldnames(s2);
    % first look for missing fields
    % fields in f2 not in f1
    f3=setdiffcellstrings(f1,f2);
    for i=1:length(f3)% StackF.Length>0
        f=f3{i};
        if isstruct(s2.(f))
            s1.(f)=struct;
            if verbose
                disp(sprintf('add struct'));
            end
        else
            if ischar(s2.(f))
                s1.(f)='';
                if verbose
                    disp(sprintf('add char field'));
                end
            else
                s1.(f)=[];
                if verbose
                    disp(sprintf('add number field'));
                end
            end
        end
    end
    % fields in f1 not in f2
    f3=setdiffcellstrings(f2,f1);
    for i=1:length(f3)% StackF.Length>0
        f=f3{i};
        if isstruct(s1.(f))
            s2.(f)=struct;
            if verbose
                disp(sprintf('add struct'));
            end
        else
            if ischar(s1.(f))
                s2.(f)='';
                if verbose
                    disp(sprintf('add char field'));
                end
            else
                s2.(f)=[];
                if verbose
                    disp(sprintf('add number field'));
                end
            end
        end
    end
    % then check all structures 
    for i=1:length(f2)
        f=f2{i};
        if isstruct(s2.(f))
            if length(s2.(f))<=1
                s1.(f)=ReconcileFields(s1.(f),s2.(f));
            end % else ignore such arrays
        end
    end
    for i=1:length(f1)
        f=f1{i};
        if isstruct(s1.(f))
            if length(s1.(f))<=1
                s2.(f)=ReconcileFields(s2.(f),s1.(f));
            end % else ignore such arrays
        end
    end
end

function f1s=setdiffcellstrings(f1,f2)
    % %fields in f2 not in f1
    flags2=zeros(length(f2),1);
    for i=1:length(f1)
        s1=f1{i};
        for j=1:length(f2)
            s2=f2{j};
            if strcmp(s1,s2)
                flags2(j)=1;
            end
        end
    end
    ind=find(flags2==0);
    f1s=f2(ind); %fields in f2 not in f1
end