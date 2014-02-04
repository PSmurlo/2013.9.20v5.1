function [] = setPlotData(sortedData,i)% works for i or j. sorteddataA or sorteddataC
if get(handles.radioAlencon,'Value') == 1
    if get(handles.VD_DPW,'Value') == 1
        set(handles.sp1,'xdata',sortedData(i,4));
        set(handles.sp1,'ydata',sortedData(i,2));
    else
        set(handles.sp1,'xdata',sortedData(i,4));
        set(handles.sp1,'ydata',sortedData(i,3));
        
    end
else
    if get(handles.VD_DPW,'Value') == 1
        set(handles.sp2,'xdata',sortedData(i,4));
        set(handles.sp2,'ydata',sortedData(i,2));
    else
        set(handles.sp2,'xdata',sortedData(i,4));
        set(handles.sp2,'ydata',sortedData(i,3));
        
    end
end
