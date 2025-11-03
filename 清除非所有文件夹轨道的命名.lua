-- 一键清除所有最后一级子轨道的轨道名
function clear_last_level_track_names()
    local project = 0 -- 当前工程
    local track_count = reaper.CountTracks(project)
    
    for i = 0, track_count - 1 do
        local track = reaper.GetTrack(project, i)
        clear_last_level_track_names_recursive(track)
    end
    
    reaper.UpdateArrange()
    reaper.ShowMessageBox("已清除所有最后一级子轨道的轨道名", "完成", 0)
end

-- 递归函数：清除最后一级子轨道的轨道名
function clear_last_level_track_names_recursive(track)
    local folder_depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    
    -- 检查是否是文件夹轨道
    if folder_depth == 1 then
        -- 这是文件夹轨道，查找其所有子轨道
        local track_idx = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER") - 1
        local next_track_idx = track_idx + 1
        
        while next_track_idx < reaper.CountTracks(project) do
            local next_track = reaper.GetTrack(project, next_track_idx)
            local next_depth = reaper.GetMediaTrackInfo_Value(next_track, "I_FOLDERDEPTH")
            
            if next_depth < 0 then
                -- 这是文件夹的结束标记，停止搜索
                break
            elseif next_depth == 0 then
                -- 这是最后一级子轨道，清除轨道名
                reaper.GetSetMediaTrackInfo_String(next_track, "P_NAME", "", true)
            elseif next_depth == 1 then
                -- 这是嵌套的文件夹轨道，递归处理
                clear_last_level_track_names_recursive(next_track)
            end
            
            next_track_idx = next_track_idx + 1
        end
    end
end

-- 运行主函数
clear_last_level_track_names()
