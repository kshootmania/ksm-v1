#pragma once

#ifdef _WIN32
#define DLL_EXPORT extern "C" __declspec(dllexport)
#else
#define DLL_EXPORT extern "C" __attribute__((visibility ("default")))
#endif

class LineGraph;

DLL_EXPORT LineGraph *CreateLineGraph();

DLL_EXPORT void DestroyLineGraph(LineGraph *pLineGraph);

DLL_EXPORT void InsertPointToLineGraph(LineGraph *pLineGraph, int measure, double v);

DLL_EXPORT void LineGraphValueAt(const LineGraph *pLineGraph, int measure, double *pRet);

DLL_EXPORT bool LineGraphContains(const LineGraph *pLineGraph, int measure);

#undef DLL_EXPORT
