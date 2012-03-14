function manchester( bitstream )
    %MANCHESTER Manchester encoding
    %   sample data:
    %       d = [ 0 1 0 0 1 1 0 0 0 1 1 ]
    %   usage:
    %       manchester(d)
    %   author:
    %       Anastasios Latsas

    % pulse height
    pulse = 0.85;

    for bit = 1:length(bitstream)
        % set bit time
        bt = bit-1:0.001:bit;

        if bitstream(bit) == 1
            % low -> high
            y = (bt<bit) * pulse - 2 * pulse * (bt < bit - 0.5);
            % set last pulse point to high level
            current_level = pulse;
        else
            % high -> low
            y = -(bt<bit) * pulse + 2 * pulse * (bt < bit - 0.5);
            % set last pulse point to low level
            current_level = -pulse;
        end

        try
            % if the next bit is the same as this one change the level
            if bitstream(bit+1) == bitstream(bit)
                y(end) = -current_level;
            else
                y(end) = current_level;
            end
        catch e
            % assume next bit is the same as the last one
            y(end) = current_level;
        end
        % draw pulse and bit label
        plot(bt, y, 'LineWidth', 2)
        text(bit-0.5, pulse+0.5, num2str(bitstream(bit)), ...
            'FontWeight', 'bold')
        hold on
    end
    % draw grids
    grid on
    axis([0 length(bitstream) -pulse-1 pulse+1]);
    set(gca,'YTick', [-pulse 0 pulse])
    set(gca,'XTick', 1:length(bitstream))
    set(gca,'XTickLabel', '')
    title('Manchester Encoding')
end
