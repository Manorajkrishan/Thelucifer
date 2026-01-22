import { useState, useEffect, useRef } from 'react'
import Head from 'next/head'
import Link from 'next/link'
import { useRouter } from 'next/router'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
const ML_SERVICE_URL = process.env.NEXT_PUBLIC_ML_SERVICE_URL || 'http://localhost:5000'

export default function Documents() {
  const router = useRouter()
  const [documents, setDocuments] = useState([])
  const [loading, setLoading] = useState(true)
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(null)
  const [token, setToken] = useState(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')
  const [driveLink, setDriveLink] = useState('')
  const [learningFromDrive, setLearningFromDrive] = useState(false)
  const [driveLinks, setDriveLinks] = useState([''])
  const fileInputRef = useRef(null)

  useEffect(() => {
    const storedToken = localStorage.getItem('token')
    setToken(storedToken)

    if (storedToken) {
      fetchDocuments(storedToken)
    } else {
      setLoading(false)
      setError('Please login to view documents')
    }
  }, [filterStatus, searchTerm])

  const fetchDocuments = async (authToken) => {
    try {
      setLoading(true)
      let url = `${API_URL}/api/documents?per_page=50`
      if (filterStatus !== 'all') {
        url += `&status=${filterStatus}`
      }
      if (searchTerm) {
        url += `&search=${encodeURIComponent(searchTerm)}`
      }

      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        }
      })

      if (!response.ok) {
        throw new Error('Failed to fetch documents')
      }

      const data = await response.json()
      let docsArray = []
      if (data.success && data.data) {
        if (data.data.data && Array.isArray(data.data.data)) {
          docsArray = data.data.data
        } else if (Array.isArray(data.data)) {
          docsArray = data.data
        }
      } else if (Array.isArray(data)) {
        docsArray = data
      } else if (data.documents && Array.isArray(data.documents)) {
        docsArray = data.documents
      }
      
      if (!Array.isArray(docsArray)) {
        docsArray = []
      }
      
      setDocuments(docsArray)
      setError(null)
    } catch (err) {
      setError(err.message)
      setDocuments([])
    } finally {
      setLoading(false)
    }
  }

  const handleUpload = async (e) => {
    e.preventDefault()
    const file = fileInputRef.current?.files[0]
    
    if (!file) {
      setError('Please select a file')
      return
    }

    if (!token) {
      setError('Please login to upload documents')
      return
    }

    try {
      setUploading(true)
      setError(null)
      setSuccess(null)

      const formData = new FormData()
      formData.append('file', file)
      formData.append('title', file.name)

      const response = await fetch(`${API_URL}/api/documents`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`
          // Don't set Content-Type for FormData - browser will set it with boundary
        },
        body: formData
      })

      const data = await response.json()

      if (!response.ok) {
        // Handle validation errors (422)
        if (response.status === 422) {
          let errorMsg = 'Validation failed: '
          
          if (data.errors) {
            const errorMessages = Object.entries(data.errors)
              .map(([field, messages]) => {
                const msgArray = Array.isArray(messages) ? messages : [messages]
                return `${field}: ${msgArray.join(', ')}`
              })
              .join('; ')
            errorMsg += errorMessages
          } else if (data.error) {
            errorMsg += data.error
          } else if (data.message) {
            errorMsg += data.message
          } else {
            errorMsg += 'Unknown validation error'
          }
          
          console.error('Upload validation error:', data)
          throw new Error(errorMsg)
        }
        
        console.error('Upload error:', data)
        throw new Error(data.message || data.error || `Upload failed (${response.status})`)
      }

      setSuccess('Document uploaded successfully!')
      fileInputRef.current.value = ''
      fetchDocuments(token)
    } catch (err) {
      setError(err.message || 'Failed to upload document')
    } finally {
      setUploading(false)
    }
  }

  const handleDownload = async (doc) => {
    if (!token) return

    try {
      const response = await fetch(`${API_URL}/api/documents/${doc.id}/download`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (!response.ok) {
        throw new Error('Download failed')
      }

      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = doc.filename || doc.title || 'document'
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (err) {
      setError(err.message || 'Failed to download document')
    }
  }

  const handleProcess = async (doc) => {
    if (!token) return

    try {
      setError(null)
      setSuccess(null)

      const response = await fetch(`${API_URL}/api/documents/${doc.id}/process`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.message || 'Processing failed')
      }

      setSuccess(`Document processing initiated for: ${doc.title}`)
      fetchDocuments(token)
    } catch (err) {
      setError(err.message || 'Failed to process document')
    }
  }

  const handleDelete = async (doc) => {
    if (!token) return
    if (!confirm(`Are you sure you want to delete "${doc.title}"?`)) return

    try {
      setError(null)
      setSuccess(null)

      const response = await fetch(`${API_URL}/api/documents/${doc.id}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })

      if (!response.ok) {
        throw new Error('Delete failed')
      }

      setSuccess('Document deleted successfully')
      fetchDocuments(token)
    } catch (err) {
      setError(err.message || 'Failed to delete document')
    }
  }

  const handleLearnFromDriveLink = async (e) => {
    e.preventDefault()
    if (!driveLink.trim()) {
      setError('Please enter a Google Drive link')
      return
    }

    try {
      setLearningFromDrive(true)
      setError(null)
      setSuccess(null)

      const response = await fetch(`${ML_SERVICE_URL}/api/v1/learning/drive-link`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          drive_link: driveLink.trim(),
          auto_learn: true
        })
      })

      const data = await response.json()

      if (!response.ok) {
        // Check if it's a folder link error
        if (data.error && data.error.includes('folder') || data.details?.error?.includes('folder')) {
          throw new Error('Folder links are not supported. Please use individual file links instead. See help below.')
        }
        throw new Error(data.error || data.details?.error || 'Failed to learn from Drive link')
      }

      // Save document to Laravel API database
      if (data.result && data.result.filename) {
        try {
          // Extract file type from filename or file_path
          const filePath = data.result.file_path || data.result.filename
          const fileExt = filePath.split('.').pop()?.toLowerCase() || 'txt'
          const validTypes = ['pdf', 'docx', 'txt', 'doc']
          const fileType = validTypes.includes(fileExt) ? fileExt : 'txt'

          const saveResponse = await fetch(`${API_URL}/api/documents`, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              title: data.result.filename,
              filename: data.result.filename,
              file_path: data.result.file_path || `downloaded/${data.result.filename}`,
              file_type: fileType,
              file_size: 0, // Size not available from ML service
              status: 'processed',
              metadata: {
                source: 'google_drive',
                drive_link: driveLink.trim()
              }
            })
          })

          if (saveResponse.ok) {
            const saveData = await saveResponse.json()
            console.log('Document saved successfully:', saveData)
            setSuccess(`Successfully downloaded, learned, and saved! Document: ${data.result.filename}`)
            // Refresh documents list after a short delay to ensure database is updated
            setTimeout(() => {
              fetchDocuments(token)
            }, 500)
          } else {
            const errorData = await saveResponse.json().catch(() => ({}))
            console.error('Failed to save document:', errorData)
            setError(`Document learned but failed to save: ${errorData.error || errorData.message || 'Unknown error'}`)
            // Still refresh to see if it was saved anyway
            setTimeout(() => {
              fetchDocuments(token)
            }, 500)
          }
        } catch (saveErr) {
          // Document learned but save failed
          console.error('Failed to save document to database:', saveErr)
          setError(`Document learned but failed to save: ${saveErr.message}`)
          // Still refresh to see if it was saved anyway
          setTimeout(() => {
            fetchDocuments(token)
          }, 500)
        }
      } else {
        setSuccess(`Successfully downloaded and learned from Drive link!`)
        // Refresh anyway
        setTimeout(() => {
          fetchDocuments(token)
        }, 500)
      }

      setDriveLink('')
    } catch (err) {
      let errorMsg = err.message || 'Failed to learn from Drive link'
      
      // Add helpful message for folder links
      if (errorMsg.includes('folder') || driveLink.includes('/folders/')) {
        errorMsg += '\n\n💡 Tip: Use individual file links instead. Right-click each file in Google Drive → "Get link" → Use that link here.'
      }
      
      setError(errorMsg)
    } finally {
      setLearningFromDrive(false)
    }
  }

  const handleLearnFromMultipleDriveLinks = async (e) => {
    e.preventDefault()
    const validLinks = driveLinks.filter(link => link.trim())
    
    if (validLinks.length === 0) {
      setError('Please enter at least one Google Drive link')
      return
    }

    try {
      setLearningFromDrive(true)
      setError(null)
      setSuccess(null)

      const response = await fetch(`${ML_SERVICE_URL}/api/v1/learning/drive-links`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          drive_links: validLinks.map(link => link.trim()),
          auto_learn: true
        })
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || 'Failed to learn from Drive links')
      }

      // Save successful documents to Laravel API database
      if (data.result && data.result.successful && Array.isArray(data.result.successful)) {
        let savedCount = 0
        for (const doc of data.result.successful) {
          if (doc.filename) {
            try {
              // Extract file type
              const filePath = doc.file_path || doc.filename
              const fileExt = filePath.split('.').pop()?.toLowerCase() || 'txt'
              const validTypes = ['pdf', 'docx', 'txt', 'doc']
              const fileType = validTypes.includes(fileExt) ? fileExt : 'txt'

              const saveResponse = await fetch(`${API_URL}/api/documents`, {
                method: 'POST',
                headers: {
                  'Authorization': `Bearer ${token}`,
                  'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                  title: doc.filename,
                  filename: doc.filename,
                  file_path: doc.file_path || `downloaded/${doc.filename}`,
                  file_type: fileType,
                  file_size: 0,
                  status: 'processed',
                  metadata: {
                    source: 'google_drive'
                  }
                })
              })
              if (saveResponse.ok) {
                savedCount++
              }
            } catch (saveErr) {
              console.warn(`Failed to save document ${doc.filename}:`, saveErr)
            }
          }
        }
        setSuccess(`Successfully processed ${validLinks.length} Drive link(s)! ${savedCount} document(s) saved.`)
      } else {
        setSuccess(`Successfully processed ${validLinks.length} Drive link(s)!`)
      }

      setDriveLinks([''])
      // Refresh documents list
      await fetchDocuments(token)
    } catch (err) {
      setError(err.message || 'Failed to learn from Drive links')
    } finally {
      setLearningFromDrive(false)
    }
  }

  const addDriveLinkField = () => {
    setDriveLinks([...driveLinks, ''])
  }

  const removeDriveLinkField = (index) => {
    if (driveLinks.length > 1) {
      setDriveLinks(driveLinks.filter((_, i) => i !== index))
    }
  }

  const updateDriveLink = (index, value) => {
    const newLinks = [...driveLinks]
    newLinks[index] = value
    setDriveLinks(newLinks)
  }

  return (
    <>
      <Head>
        <title>Documents - SentinelAI X</title>
        <meta name="description" content="Manage cybersecurity documents" />
      </Head>

      <div className="min-h-screen bg-gray-50">
        <header className="bg-white shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="flex justify-between items-center">
              <h1 className="text-2xl font-bold text-gray-900">Documents</h1>
              <div className="flex gap-4">
                <Link href="/dashboard" className="text-blue-600 hover:text-blue-800">
                  Dashboard
                </Link>
                <Link href="/threats" className="text-gray-600 hover:text-gray-800">
                  Threats
                </Link>
                <Link href="/simulations" className="text-gray-600 hover:text-gray-800">
                  Simulations
                </Link>
                <Link href="/analytics" className="text-gray-600 hover:text-gray-800">
                  Analytics
                </Link>
                <Link href="/learning" className="text-gray-600 hover:text-gray-800">
                  Learning
                </Link>
              </div>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {!token ? (
            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
              <p className="text-yellow-800 mb-4">Please login to view documents</p>
              <Link href="/login" className="inline-block bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                Go to Login
              </Link>
            </div>
          ) : (
            <div className="space-y-6">
              {/* Messages */}
              {error && (
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <p className="text-red-800">{error}</p>
                </div>
              )}
              {success && (
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <p className="text-green-800">{success}</p>
                </div>
              )}

              {/* Upload Section */}
              <div className="bg-white rounded-lg shadow p-6">
                <h2 className="text-xl font-semibold mb-4">Upload Document</h2>
                <form onSubmit={handleUpload} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Select Document (PDF, DOCX, DOC, TXT - Max 10MB)
                    </label>
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept=".pdf,.docx,.doc,.txt"
                      className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                      required
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={uploading}
                    className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {uploading ? 'Uploading...' : 'Upload Document'}
                  </button>
                </form>
              </div>

              {/* Learn from Google Drive Link Section */}
              <div className="bg-white rounded-lg shadow p-6 border-2 border-purple-200">
                <h2 className="text-xl font-semibold mb-2">📚 Learn from Google Drive Link</h2>
                <p className="text-sm text-gray-600 mb-4">
                  Provide a Google Drive link and the system will automatically download, process, and learn from the document.
                </p>
                
                <div className="bg-purple-50 border border-purple-200 rounded-lg p-4 mb-4">
                  <p className="text-sm text-purple-800 font-semibold mb-2">Supported Link Formats:</p>
                  <ul className="text-xs text-purple-700 space-y-1 list-disc list-inside">
                    <li>https://drive.google.com/file/d/FILE_ID/view</li>
                    <li>https://drive.google.com/open?id=FILE_ID</li>
                    <li>https://drive.google.com/uc?export=download&id=FILE_ID</li>
                    <li>Any publicly accessible file URL</li>
                  </ul>
                </div>

                <form onSubmit={handleLearnFromDriveLink} className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Google Drive Link
                    </label>
                    <input
                      type="url"
                      value={driveLink}
                      onChange={(e) => setDriveLink(e.target.value)}
                      placeholder="https://drive.google.com/file/d/YOUR_FILE_ID/view"
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                      required
                    />
                  </div>
                  <button
                    type="submit"
                    disabled={learningFromDrive}
                    className="bg-purple-600 text-white px-6 py-2 rounded-lg hover:bg-purple-700 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {learningFromDrive ? 'Downloading & Learning...' : '📥 Download & Learn from Drive'}
                  </button>
                </form>
              </div>

              {/* Learn from Multiple Drive Links */}
              <div className="bg-white rounded-lg shadow p-6 border-2 border-indigo-200">
                <h2 className="text-xl font-semibold mb-2">📚 Learn from Multiple Drive Links</h2>
                <p className="text-sm text-gray-600 mb-4">
                  Process multiple Google Drive links at once for batch learning.
                </p>

                <form onSubmit={handleLearnFromMultipleDriveLinks} className="space-y-4">
                  {driveLinks.map((link, index) => (
                    <div key={index} className="flex gap-2">
                      <input
                        type="url"
                        value={link}
                        onChange={(e) => updateDriveLink(index, e.target.value)}
                        placeholder={`Drive link ${index + 1}...`}
                        className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
                      />
                      {driveLinks.length > 1 && (
                        <button
                          type="button"
                          onClick={() => removeDriveLinkField(index)}
                          className="px-4 py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200"
                        >
                          Remove
                        </button>
                      )}
                    </div>
                  ))}
                  <div className="flex gap-2">
                    <button
                      type="button"
                      onClick={addDriveLinkField}
                      className="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
                    >
                      + Add Another Link
                    </button>
                    <button
                      type="submit"
                      disabled={learningFromDrive}
                      className="flex-1 bg-indigo-600 text-white px-6 py-2 rounded-lg hover:bg-indigo-700 disabled:opacity-50"
                    >
                      {learningFromDrive ? 'Processing...' : '📥 Process All Links'}
                    </button>
                  </div>
                </form>
              </div>

              {/* Filters */}
              <div className="bg-white rounded-lg shadow p-4">
                <div className="flex gap-4 items-center">
                  <div className="flex-1">
                    <input
                      type="text"
                      placeholder="Search documents..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    />
                  </div>
                  <select
                    value={filterStatus}
                    onChange={(e) => setFilterStatus(e.target.value)}
                    className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="all">All Status</option>
                    <option value="uploaded">Uploaded</option>
                    <option value="processing">Processing</option>
                    <option value="processed">Processed</option>
                    <option value="failed">Failed</option>
                  </select>
                </div>
              </div>

              {/* Documents List */}
              <div className="bg-white rounded-lg shadow">
                <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                  <h2 className="text-xl font-semibold">All Documents ({documents.length})</h2>
                  <button
                    onClick={() => fetchDocuments(token)}
                    className="text-sm text-blue-600 hover:text-blue-800"
                  >
                    Refresh
                  </button>
                </div>
                {loading ? (
                  <div className="px-6 py-12 text-center">
                    <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
                    <p className="mt-4 text-gray-600">Loading documents...</p>
                  </div>
                ) : !Array.isArray(documents) || documents.length === 0 ? (
                  <div className="px-6 py-12 text-center text-gray-500">
                    <p>No documents found. Upload your first document above.</p>
                  </div>
                ) : (
                  <div className="divide-y divide-gray-200">
                    {documents.map((doc) => (
                      <div key={doc.id} className="px-6 py-4 hover:bg-gray-50">
                        <div className="flex justify-between items-start">
                          <div className="flex-1">
                            <h3 className="text-lg font-medium text-gray-900">{doc.title || doc.filename || 'Untitled Document'}</h3>
                            <p className="text-sm text-gray-500 mt-1">
                              {doc.description || 'No description'}
                            </p>
                            <div className="flex gap-4 mt-2 text-sm text-gray-600">
                              <span>Type: {doc.file_type || 'unknown'}</span>
                              <span>Size: {doc.file_size ? `${(doc.file_size / 1024).toFixed(2)} KB` : 'N/A'}</span>
                              <span className={`px-2 py-1 rounded text-xs ${
                                doc.status === 'processed' ? 'bg-green-100 text-green-800' :
                                doc.status === 'processing' ? 'bg-yellow-100 text-yellow-800' :
                                doc.status === 'failed' ? 'bg-red-100 text-red-800' :
                                'bg-gray-100 text-gray-800'
                              }`}>
                                {doc.status || 'uploaded'}
                              </span>
                              {doc.created_at && (
                                <span>Uploaded: {new Date(doc.created_at).toLocaleDateString()}</span>
                              )}
                            </div>
                          </div>
                          <div className="flex gap-2 ml-4">
                            <button
                              onClick={() => handleDownload(doc)}
                              className="text-green-600 hover:text-green-800 text-sm font-medium"
                            >
                              Download
                            </button>
                            {doc.status !== 'processed' && (
                              <button
                                onClick={() => handleProcess(doc)}
                                className="text-purple-600 hover:text-purple-800 text-sm font-medium"
                              >
                                Process
                              </button>
                            )}
                            <button
                              onClick={() => handleDelete(doc)}
                              className="text-red-600 hover:text-red-800 text-sm font-medium"
                            >
                              Delete
                            </button>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}
        </main>
      </div>
    </>
  )
}
