# DCA1000 Radar Data Processing

本项目用于处理 TI DCA1000 雷达采集的数据，包括参数配置、数据解析、分离、FFT 处理及可视化。

## 目录结构

- `main.m`：主程序入口，负责调用各模块完成数据处理和可视化。
- `RadarParamentsConfig.m`：雷达参数配置。
- `PrintfParamentsConfig.m`：绘图参数配置。
- `DataParsing.m`：原始 bin 文件数据解析为 ADC 数据矩阵。
- `DataSeperate.m`：TDM 模式下数据分离，生成三维数据矩阵。
- `PrintfPic.m`：距离/速度 FFT 及可视化。
- `readDCA1000.m`：DCA1000 数据读取辅助函数。

## 使用方法

1. 修改 `main.m` 中的数据文件路径和文件名（`datafolder` 和 `binfileName`）。
2. 运行 `main.m`，自动完成数据解析、分离、FFT 处理及绘图。
3. 可根据需要调整参数配置文件中的参数。

## 依赖环境

- MATLAB R2016a 及以上版本
- DCA1000 采集的原始 bin 数据文件

## 主要流程

1. 配置雷达和绘图参数。
2. 读取并解析 bin 数据文件。
3. 数据分离为三维矩阵（采样点 × chirp × 接收通道）。
4. 距离和速度 FFT 处理。
5. 绘制时域波形、距离谱和距离-速度图、距离-角度图。

## 注意

1. 生成距离-角度图仅限于ULA MIMO，否则会出错。

## 联系方式

如有问题或建议，请联系项目维护者luway158@gmail.com