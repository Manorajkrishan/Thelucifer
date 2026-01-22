<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Document;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Http;

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
        // Check if this is a JSON document creation (Drive download) vs file upload
        // JSON creation: has filename, file_path, file_type but NO actual file upload
        // File upload: has actual file in request
        
        // Check if this is JSON document creation (Drive download)
        // Accept both 'application/json' and 'application/json; charset=utf-8'
        $contentType = $request->header('Content-Type', '');
        $isJsonContentType = str_contains($contentType, 'application/json');
        
        $isJsonDocument = $request->has('filename') && 
                         $request->has('file_path') && 
                         $request->has('file_type') && 
                         !$request->hasFile('file') &&
                         $isJsonContentType;
        
        if ($isJsonDocument) {
            // Create document from Drive download (JSON format)
            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:255',
                'filename' => 'required|string|max:255',
                'file_path' => 'required|string',
                'file_type' => 'required|string|in:pdf,docx,txt,doc',
                'file_size' => 'nullable|integer|min:0',
                'status' => 'nullable|string|in:uploaded,processing,processed,failed',
                'metadata' => 'nullable|array',
            ]);

            if ($validator->fails()) {
                \Log::warning('JSON document validation failed', [
                    'errors' => $validator->errors()->toArray(),
                    'request_data' => $request->except(['metadata']),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                    'error' => $validator->errors()->first(),
                ], 422);
            }

            try {
                // Prepare metadata
                $metadata = $request->metadata ?? [];
                if (!isset($metadata['source'])) {
                    $metadata['source'] = 'google_drive';
                }
                if (!isset($metadata['drive_link']) && $request->has('drive_link')) {
                    $metadata['drive_link'] = $request->drive_link;
                }

                \Log::info('Creating document from Drive download (JSON)', [
                    'title' => $request->title,
                    'filename' => $request->filename,
                    'file_path' => $request->file_path,
                    'file_type' => $request->file_type,
                    'metadata' => $metadata,
                ]);

                $document = Document::create([
                    'title' => $request->title,
                    'filename' => $request->filename,
                    'file_path' => $request->file_path,
                    'file_type' => $request->file_type,
                    'file_size' => $request->file_size ?? 0,
                    'status' => $request->status ?? 'processed',
                    'uploaded_by' => auth()->id(),
                    'metadata' => $metadata,
                ]);

                \Log::info('Document created successfully from JSON', ['document_id' => $document->id]);

                // Automatically trigger learning from this document
                $this->triggerDocumentLearning($document);

                return response()->json([
                    'success' => true,
                    'data' => $document,
                    'message' => 'Document saved successfully',
                ], 201);
            } catch (\Exception $e) {
                \Log::error('Failed to save document from Drive (JSON)', [
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to save document',
                    'error' => $e->getMessage(),
                ], 500);
            }
        }

        // Regular file upload - only if an actual file is being uploaded
        if (!$request->hasFile('file')) {
            return response()->json([
                'success' => false,
                'message' => 'No file uploaded',
                'error' => 'Please provide a file to upload or use the JSON format for Drive-downloaded documents',
                'hint' => 'For Drive downloads, ensure filename, file_path, and file_type are provided in JSON format',
            ], 422);
        }

        // Debug: Log what we received
        \Log::info('Document upload request', [
            'has_file' => $request->hasFile('file'),
            'all_keys' => array_keys($request->all()),
            'files' => array_keys($request->allFiles()),
        ]);

        $validator = Validator::make($request->all(), [
            'file' => 'required|file|mimes:pdf,docx,txt,doc|max:10240', // max:10240 = 10MB in kilobytes
            'title' => 'nullable|string|max:255',
        ], [
            'file.required' => 'Please select a file to upload',
            'file.file' => 'The uploaded file is not valid',
            'file.mimes' => 'The file must be a PDF, DOCX, DOC, or TXT file',
            'file.max' => 'The file size must not exceed 10MB (10240 KB)',
        ]);

        if ($validator->fails()) {
            $errors = $validator->errors();
            \Log::warning('Document upload validation failed', [
                'errors' => $errors->toArray(),
                'request_data' => [
                    'has_file' => $request->hasFile('file'),
                    'file_size' => $request->hasFile('file') ? $request->file('file')->getSize() : null,
                    'file_mime' => $request->hasFile('file') ? $request->file('file')->getMimeType() : null,
                ]
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $errors->toArray(),
                'error' => $errors->first(),
            ], 422);
        }

        $file = $request->file('file');
        
        if (!$file) {
            return response()->json([
                'success' => false,
                'message' => 'No file uploaded',
                'error' => 'The file field is required',
            ], 422);
        }
        
        // Ensure storage directory exists
        $storagePath = storage_path('app/public/documents');
        if (!is_dir($storagePath)) {
            mkdir($storagePath, 0755, true);
        }
        
        $filename = time() . '_' . $file->getClientOriginalName();
        $filePath = $file->storeAs('documents', $filename, 'public');

        try {
            $document = Document::create([
                'title' => $request->title ?? $file->getClientOriginalName(),
                'filename' => $file->getClientOriginalName(),
                'file_path' => $filePath,
                'file_type' => $file->getClientOriginalExtension(),
                'file_size' => $file->getSize(),
                'status' => 'uploaded',
                'uploaded_by' => auth()->id(),
            ]);
        } catch (\Exception $e) {
            // Delete uploaded file if database insert fails
            Storage::disk('public')->delete($filePath);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to save document',
                'error' => $e->getMessage(),
            ], 500);
        }

        // Automatically trigger learning from this document
        $this->triggerDocumentLearning($document);

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
     * Trigger document processing and learning
     */
    public function process(Document $document): JsonResponse
    {
        try {
            $result = $this->triggerDocumentLearning($document);
            
            return response()->json([
                'success' => true,
                'message' => 'Document processing initiated',
                'learning_result' => $result,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to process document',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Trigger learning from document in ML service
     */
    private function triggerDocumentLearning(Document $document): ?array
    {
        try {
            $mlServiceUrl = env('ML_SERVICE_URL', 'http://localhost:5000');
            
            // For Drive downloads, ML service already processed the document
            // So we just need to trigger learning from the extracted data
            $metadata = $document->metadata ?? [];
            if (isset($metadata['source']) && $metadata['source'] === 'google_drive') {
                // Document was already processed by ML service during Drive download
                // Just trigger learning from existing extracted data if available
                if ($document->extracted_data) {
                    $this->triggerLearningFromExtractedData($document->extracted_data);
                }
                return ['message' => 'Document already processed by ML service'];
            }

            // For regular uploads, send to ML service for processing
            $filePath = $document->file_path;
            
            // If file_path starts with "downloaded/", it's from ML service
            if (str_starts_with($filePath, 'downloaded/')) {
                $fullPath = $filePath;
            } else {
                // File is in Laravel storage
                $fullPath = storage_path('app/public/' . $filePath);
            }

            // Send document to ML service for processing and learning
            $response = Http::timeout(30)->post("{$mlServiceUrl}/api/v1/documents/process", [
                'document_id' => "doc_{$document->id}",
                'file_path' => $fullPath,
                'file_type' => $document->file_type,
            ]);

            if ($response->successful()) {
                $result = $response->json();
                
                // Update document with extracted data
                if (isset($result['extracted_data'])) {
                    $document->update([
                        'extracted_data' => $result['extracted_data'],
                        'status' => 'processed',
                        'processed_at' => now(),
                    ]);

                    // Trigger learning from extracted data
                    $this->triggerLearningFromExtractedData($result['extracted_data']);
                }

                \Log::info('Document sent to ML service for learning', [
                    'document_id' => $document->id,
                ]);

                return $result;
            }
            
            return null;
            
        } catch (\Exception $e) {
            \Log::error('Failed to trigger document learning', [
                'document_id' => $document->id,
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }

    /**
     * Trigger learning from extracted document data
     */
    private function triggerLearningFromExtractedData(array $extractedData): void
    {
        try {
            $mlServiceUrl = env('ML_SERVICE_URL', 'http://localhost:5000');
            
            Http::timeout(30)->post("{$mlServiceUrl}/api/v1/learning/learn", [
                'type' => 'documents',
                'documents' => [$extractedData],
            ]);

            \Log::info('Triggered learning from extracted document data');
            
        } catch (\Exception $e) {
            \Log::error('Failed to trigger learning from extracted data', [
                'error' => $e->getMessage(),
            ]);
        }
    }
}
