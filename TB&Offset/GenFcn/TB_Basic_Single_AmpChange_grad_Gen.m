function res = TB_Basic_Single_AmpChange_grad_Gen(Order_Std, Amp, GradValue, varargin)
mIp = inputParser;
mIp.addRequired("Order_Std",  @(x) isstruct(x));
mIp.addRequired("Amp",  @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addRequired("GradValue",  @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.parse(Order_Std, Amp, GradValue, varargin{:});

Order_Std = mIp.Results.Order_Std;
Amp = mIp.Results.Amp;
GradValue = mIp.Results.GradValue;

if isempty(Order_Std)
    error("Order_Std is missing!!!");
end
tempWave = Order_Std.Wave;
Gindex = find(tempWave>0);
GradAmp = linspace(Amp, GradValue, length(Gindex)); 
tempWave(Gindex) = GradAmp;
GradWave = tempWave;

res.Name = strcat("TB_Reg_ICI", strrep(num2str(Order_Std.ICIs), ".", "o"), "_Dur", num2str(Order_Std.Duration), "_Grad", strrep(num2str(GradValue), ".", "o"));
res.Wave = GradWave;
res.ICISeq = [Order_Std.ICIs];
res.Onset_Index = find(diff([0; res.Wave]) > 0);
res.Interval = diff(res.Onset_Index);
res.fs = Order_Std.fs;
res.SeqOffset = sum(res.Interval) / res.fs;

end


