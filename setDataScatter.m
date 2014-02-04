function [] = setDataScatter(handles,sortedData)% works for i or j. sorteddataA or sorteddataC
if get(handles.radioAlencon,'Value') == 1
    if get(handles.VD_DPW,'Value') == 1
        set(handles.s1,'xdata',sortedData(:,4));
        set(handles.s1,'ydata',sortedData(:,2));
    else
        set(handles.s1,'xdata',sortedData(:,4));
        set(handles.s1,'ydata',sortedData(:,3));       
    end
else
    if get(handles.VD_DPW,'Value') == 1
        set(handles.s2,'xdata',sortedData(:,4));
        set(handles.s2,'ydata',sortedData(:,2));
    else
        set(handles.s2,'xdata',sortedData(:,4));
        set(handles.s2,'ydata',sortedData(:,3));        
    end
end
