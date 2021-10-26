function     printSetupCode(H)
    cases={};
    casehandlers={};
    casesetups={};
    casecallsetups={};
    for i=1:length(H)
        name=get(H(i),'tag');
        type=get(H(i),'type');
        if exist(name)==2
           % disp(sprintf('%s exists already',name))
        else
            if strcmpi(type,'uimenu')
                if isempty(get(H(i),'children'))
                    cases{end+1}=sprintf('case ''%s''\ndata=%s(arg);\n',name,name);
                    casesetups{end+1}=sprintf('function data=%sSetup(data)\nend\n',name);
                    casecallsetups{end+1}=sprintf('data=%sSetup(data);\n',name);
                    casehandlers{end+1}=sprintf('function data=%s(data,arg)\nend\n',name);
                end
            elseif strcmpi(type,'uicontrol')
                if ~isempty(name)
                    cases{end+1}=sprintf('case ''%s''\ndata=%s;\n',name,name);
                    casesetups{end+1}=sprintf('function data=%sSetup(data)\nend\n',name);
                    casecallsetups{end+1}=sprintf('data=%sSetup(data);\n',name);
                    casehandlers{end+1}=sprintf('function data=%s(data)\nend\n',name);
                end
            end
        end
    end
%     disp('%-------------')
%     [s,i]=sort(cases);
%     for i=1:length(cases),fprintf(1,'%s',s{i}),end
    if ~isempty(casehandlers)
        disp('\n\nPlease add the following to the existing program')
        disp('%-------------')
        [s,i]=sort(casehandlers);
        for i=1:length(cases),fprintf(1,'%s',s{i}),end
        disp('%-------------')
        [s,i]=sort(casesetups);
        for i=1:length(cases),fprintf(1,'%s',s{i}),end
        disp('%-------------')
        disp('function data=DoSetups(data)');
        [s,i]=sort(casecallsetups);
        for i=1:length(cases),fprintf(1,'%s',s{i}),end
        disp('end')
        disp('%-------------')
    end
end