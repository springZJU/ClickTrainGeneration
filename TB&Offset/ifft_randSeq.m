for vIndex = 1 : 6
    randSeq = rand(1, 1e5*10); % 10s
    save(strcat("randSeq_v", num2str(vIndex), ".mat"), "randSeq", "-mat");
end