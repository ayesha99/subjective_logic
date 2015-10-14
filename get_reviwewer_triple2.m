function triple = get_reviwewer_triple(data, reviewer1_idx, reviewer2_idx)
triple = {};
col1 = data(:,reviewer1_idx);
col2 = data(:,reviewer2_idx);
uncertain_para = .5;

aspects_n = size(data,1);
complete_row = zeros(aspects_n,1);
weight_row = zeros(aspects_n,1);
for aspect_i = 1:aspects_n
    row_i = data(aspect_i,:);
    complete_row(aspect_i) = length(find(row_i ~= 0))/length(row_i);
    if col1(aspect_i) > 0 && col2(aspect_i) > 0
        weight_row(aspect_i) = complete_row(aspect_i) .* 1 / (1 + exp(length(find(row_i>0))/length(row_i)));
    elseif col1(aspect_i) < 0 && col2(aspect_i) < 0
        weight_row(aspect_i) = complete_row(aspect_i) .* 1 / (1 + exp(length(find(row_i<0))/length(row_i)));
    elseif col1(aspect_i) == 0 || col2(aspect_i) == 0
        weight_row(aspect_i) = 0;
    else
        weight_row(aspect_i) = complete_row(aspect_i) .* 1 / (1 + exp(1/2));
    end
end
weight_row = weight_row / sum(weight_row);

agreement = zeros(aspects_n,1);
disagreement = zeros(aspects_n,1);
for aspect_i = 1:aspects_n
   if (col1(aspect_i) > 0 && col2(aspect_i) > 0) || (col1(aspect_i) < 0 && col2(aspect_i) < 0)
      agreement(aspect_i) = (1 - abs(col1(aspect_i) - col2(aspect_i))); 
      agreement(aspect_i) = agreement(aspect_i) * weight_row(aspect_i);
   elseif (col1(aspect_i) > 0 && col2(aspect_i) < 0) || col1(aspect_i) < 0 && col2(aspect_i) > 0
      disagreement(aspect_i) = abs(tan(col1(aspect_i)) - tan(col2(aspect_i)))/(tan(1) - tan(-1));
      disagreement(aspect_i) = disagreement(aspect_i) *  weight_row(aspect_i);   
   end
end
trust = sum(agreement);
distrust = sum(disagreement);

incomplete_col2 = length(find( col1 == 0 & col2 == 0))/length(col2);
incomplete_col1_col2 = length(find( col1 ~= 0 & col2 == 0))/length(col2);
uncertain = incomplete_col2 + incomplete_col1_col2;
uncertain = log(uncertain + 1) * uncertain_para;

triple.trust = trust / (trust + distrust + uncertain);
triple.distrust = distrust / (trust + distrust + uncertain);
triple.uncertain = uncertain / (trust + distrust + uncertain);

end