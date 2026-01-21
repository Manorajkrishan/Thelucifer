<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Document;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class DocumentController extends Controller
{
    /**
     * Display a listing of documents
     */
    public function index(Request $request): JsonResponse
    {
        $query = Document::query();

        // Filter by status
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by file type
        if ($request->has('file_type')) {
            $query->where('file_type', $request->file_type);
        }

        // Search
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('filename', 'like', "%{$search}%");
            });
        }

        $perPage = $request->get('per_page', 15);
        $documents = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return response()->json([
            'success' => true,
            'data' => $documents,
        ]);
    }

    /**
     * Upload and store a new document
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|mimes:pdf,docx,txt,doc|max:10240',
            'title' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
            ], 422);
        }

        $file = $request->file('file');
        $filename = time() . '_' . $file->getClientOriginalName();
        $filePath = $file->storeAs('documents', $filename, 'public');

        $document = Document::create([
            'title' => $request->title ?? $file->getClientOriginalName(),
            'filename' => $file->getClientOriginalName(),
            'file_path' => $filePath,
            'file_type' => $file->getClientOriginalExtension(),
            'file_size' => $file->getSize(),
            'status' => 'uploaded',
            'uploaded_by' => auth()->id(),
        ]);

        // Trigger document processing (async job)
        // dispatch(new ProcessDocumentJob($document));

        return response()->json([
            'success' => true,
            'data' => $document,
            'message' => 'Document uploaded successfully',
        ], 201);
    }

    /**
     * Display the specified document
     */
    public function show(Document $document): JsonResponse
    {
        $document->load('knowledgeEntries');

        return response()->json([
            'success' => true,
            'data' => $document,
        ]);
    }

    /**
     * Download the document file
     */
    public function download(Document $document)
    {
        if (!Storage::disk('public')->exists($document->file_path)) {
            return response()->json([
                'success' => false,
                'message' => 'File not found',
            ], 404);
        }

        return Storage::disk('public')->download($document->file_path, $document->filename);
    }

    /**
     * Remove the specified document
     */
    public function destroy(Document $document): JsonResponse
    {
        // Delete file from storage
        Storage::disk('public')->delete($document->file_path);

        $document->delete();

        return response()->json([
            'success' => true,
            'message' => 'Document deleted successfully',
        ]);
    }

    /**
     * Trigger document processing
     */
    public function process(Document $document): JsonResponse
    {
        if ($document->status === 'processed') {
            return response()->json([
                'success' => false,
                'message' => 'Document already processed',
            ], 400);
        }

        // Trigger ML service to process document
        // dispatch(new ProcessDocumentJob($document));

        return response()->json([
            'success' => true,
            'message' => 'Document processing initiated',
        ]);
    }
}
