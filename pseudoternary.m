function pseudoternary( bitstream )
    %PSEUDOTERNARY Pseudoternary encoding
    %   sample data:
    %       d = [ 0 1 0 0 1 1 0 0 0 1 1 ]
    %   usage:
    %       pseudoternary(d)
    %   author:
    %       Anastasios Latsas

    % pulse height
    pulse = 5;

    % assume that current pulse level is a "low" pulse (binary 0)
    % this is the pulse level for the bit before given bitstream
    current_level = -pulse;

    for bit = 1:length(bitstream)
        % set bit time
        bt=bit-1:0.001:bit;

        if bitstream(bit) == 0
            % in pseudoternary, 0 denotes a change in signal levels
            current_level = -current_level;
            y = (bt<bit) * current_level;
        else
            % binary 1 is mapped to zero
            y = zeros(size(bt));
        end

        % assign last pulse point by inspecting the following bit
        try
            if bitstream(bit+1) == 0
                y(end) = -current_level;
            end
        catch e
            % bitstream end; assume next bit is 0
            y(end) = -current_level;
        end
        % draw pulse and label
        plot(bt, y, 'LineWidth', 2);
        text(bit-0.5, pulse+2, num2str(bitstream(bit)), ...
            'FontWeight', 'bold')
        hold on;
    end
    % draw grid
    grid on;
    axis([0 length(bitstream) -pulse*2 pulse*2]);
    set(gca,'YTick', [-pulse 0 pulse])
    set(gca,'XTick', 1:length(bitstream))
    set(gca,'XTickLabel', '')
    title('Pseudoternary')
end
