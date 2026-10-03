function [phaseCorr, eigenSpread, dopplerResidual] = extractFeatures(receivedSignal)
%EXTRACTFEATURES Extract 3 detection features from received array signal
%   receivedSignal: numSamples x numElements complex matrix

    % ---------- Feature 1: Phase Correlation ----------
    % প্রতিটা চ্যানেলের phase বের করা
    phases = angle(receivedSignal);   % numSamples x numElements

    % চ্যানেলগুলোর মধ্যে pairwise phase correlation বের করে গড় করা
    corrMatrix = corrcoef(phases);
    numElem = size(receivedSignal, 2);
    offDiagSum = 0;
    count = 0;
    for i = 1:numElem
        for j = i+1:numElem
            offDiagSum = offDiagSum + abs(corrMatrix(i,j));
            count = count + 1;
        end
    end
    phaseCorr = offDiagSum / count;   % গড় absolute correlation

    % ---------- Feature 2: Eigenvalue Spread ----------
    R = (receivedSignal' * receivedSignal) / size(receivedSignal, 1);
    eigVals = sort(eig(R), 'descend');
    eigVals = real(eigVals);   % numerical safety

    % সবচেয়ে বড় আর সবচেয়ে ছোট eigenvalue-এর অনুপাত
    eigenSpread = eigVals(1) / max(eigVals(end), 1e-10);

    % ---------- Feature 3: Doppler/Timing Residual ----------
    % Simplified: প্রতিটা চ্যানেলের signal envelope-এর মধ্যে 
    % autocorrelation consistency মাপা (timing pattern-এর proxy)
    envelope = abs(receivedSignal);
    acfVals = zeros(1, numElem);
    for i = 1:numElem
        acf = xcorr(envelope(:,i) - mean(envelope(:,i)), 1, 'normalized');
        acfVals(i) = acf(end);   % lag-1 autocorrelation
    end
    dopplerResidual = std(acfVals);  % চ্যানেলগুলোর মধ্যে variation

end