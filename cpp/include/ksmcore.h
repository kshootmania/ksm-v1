#pragma once

#ifdef _WIN32
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT __attribute__((visibility ("default")))
#endif

class LineGraph;

DLL_EXPORT LineGraph *CreateLineGraph();

DLL_EXPORT void DestroyLineGraph(LineGraph *pLineGraph);

DLL_EXPORT void InsertPointToLineGraph(LineGraph *pLineGraph, int measure, double v);

DLL_EXPORT double LineGraphValueAt(const LineGraph *pLineGraph, int measure);

#undef DLL_EXPORT
