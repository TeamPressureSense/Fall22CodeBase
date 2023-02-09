tables = {test,feb23nakedTest1};
removePreload = true;
fixedPoint = min(tables{1}.VarName9);

figure
hold on
for i = 1:width(tables)

    startTime = tables{i}.VarName1(1);
    time = tables{i}.VarName1 - startTime;
    press = tables{i}.VarName9;
    
    if (removePreload)
        press = press - (min(tables{i}.VarName9) - fixedPoint);
    end
    
    plot(time,press);
    title("Naked Hydrocell versus Silicon Cover (with offset)");
    xlabel("Time Elapsed (mm:ss)");
    xtickformat("mm:ss");
    ylabel("Pressure (Pa)");
    legend(["Silicon","Naked"]);
end