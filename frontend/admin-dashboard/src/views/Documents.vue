<template>
  <div>
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-3xl font-bold">Documents</h1>
      <button 
        @click="showUploadModal = true"
        class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
      >
        Upload Document
      </button>
    </div>

    <!-- Search and Filter -->
    <div class="bg-white rounded-lg shadow p-4 mb-6">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <input
            v-model="searchTerm"
            type="text"
            placeholder="Search documents..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
            @input="fetchDocuments"
          />
        </div>
        <div>
          <select
            v-model="filterStatus"
            @change="fetchDocuments"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          >
            <option value="all">All Status</option>
            <option value="uploaded">Uploaded</option>
            <option value="processing">Processing</option>
            <option value="processed">Processed</option>
            <option value="failed">Failed</option>
          </select>
        </div>
        <div>
          <button
            @click="fetchDocuments"
            class="w-full bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-gray-700"
          >
            Refresh
          </button>
        </div>
      </div>
    </div>

    <!-- Drive Link Learning -->
    <div class="bg-white rounded-lg shadow p-6 mb-6 border-2 border-purple-200">
      <h2 class="text-xl font-semibold mb-4">📚 Learn from Google Drive Links</h2>
      <p class="text-sm text-gray-600 mb-4">
        Add multiple Google Drive file links to download and learn from them automatically.
      </p>
      
      <div class="space-y-3">
        <div v-for="(link, index) in driveLinks" :key="index" class="flex gap-2">
          <input
            v-model="driveLinks[index]"
            type="text"
            :placeholder="`Drive link ${index + 1}...`"
            class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          />
          <button
            v-if="driveLinks.length > 1"
            @click="removeDriveLink(index)"
            class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
          >
            Remove
          </button>
        </div>
        <div class="flex gap-2">
          <button
            @click="addDriveLink"
            class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700"
          >
            + Add Link
          </button>
          <button
            @click="processDriveLinks"
            :disabled="learningFromDrive"
            class="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50"
          >
            {{ learningFromDrive ? 'Processing...' : '📥 Process All Links & Learn' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Documents List -->
    <div v-if="loading" class="text-center py-12">
      <p class="text-gray-500">Loading documents...</p>
    </div>

    <div v-else-if="documents.length === 0" class="bg-white rounded-lg shadow p-12 text-center">
      <p class="text-gray-500 text-lg">No documents found</p>
      <p class="text-gray-400 text-sm mt-2">Upload a document or learn from Drive links to get started</p>
    </div>

    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Title</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Size</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Uploaded</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="doc in documents" :key="doc.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="font-medium text-gray-900">{{ doc.title }}</div>
              <div class="text-sm text-gray-500">{{ doc.filename }}</div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 uppercase">{{ doc.file_type }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatFileSize(doc.file_size) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 py-1 text-xs rounded-full" :class="getStatusClass(doc.status)">
                {{ doc.status }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatDate(doc.created_at) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm">
              <div class="flex gap-2">
                <button
                  @click="downloadDocument(doc)"
                  class="text-blue-600 hover:text-blue-800"
                >
                  Download
                </button>
                <button
                  v-if="doc.status !== 'processed'"
                  @click="processDocument(doc)"
                  class="text-green-600 hover:text-green-800"
                >
                  Process
                </button>
                <button
                  @click="deleteDocument(doc)"
                  class="text-red-600 hover:text-red-800"
                >
                  Delete
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Upload Modal -->
    <div v-if="showUploadModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full">
        <h3 class="text-xl font-bold mb-4">Upload Document</h3>
        <form @submit.prevent="handleUpload">
          <div class="mb-4">
            <input
              ref="fileInput"
              type="file"
              accept=".pdf,.docx,.doc,.txt"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              required
            />
          </div>
          <div class="flex gap-2">
            <button
              type="button"
              @click="showUploadModal = false"
              class="flex-1 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="uploading"
              class="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {{ uploading ? 'Uploading...' : 'Upload' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'
const ML_SERVICE_URL = import.meta.env.VITE_ML_SERVICE_URL || 'http://localhost:5000'

const authStore = useAuthStore()
const documents = ref([])
const loading = ref(false)
const uploading = ref(false)
const searchTerm = ref('')
const filterStatus = ref('all')
const driveLinks = ref([''])
const learningFromDrive = ref(false)
const showUploadModal = ref(false)
const fileInput = ref(null)

onMounted(() => {
  fetchDocuments()
})

const fetchDocuments = async () => {
  loading.value = true
  try {
    const params = { per_page: 50 }
    if (filterStatus.value !== 'all') {
      params.status = filterStatus.value
    }
    if (searchTerm.value) {
      params.search = searchTerm.value
    }

    const response = await axios.get(`${API_URL}/api/documents`, {
      params,
      headers: {
        Authorization: `Bearer ${authStore.token}`
      }
    })

    if (response.data.success && response.data.data) {
      documents.value = response.data.data.data || response.data.data || []
    } else {
      documents.value = []
    }
  } catch (error) {
    console.error('Failed to fetch documents:', error)
    documents.value = []
  } finally {
    loading.value = false
  }
}

const handleUpload = async () => {
  const file = fileInput.value?.files[0]
  if (!file) return

  uploading.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('title', file.name)

    await axios.post(`${API_URL}/api/documents`, formData, {
      headers: {
        Authorization: `Bearer ${authStore.token}`,
        'Content-Type': 'multipart/form-data'
      }
    })

    showUploadModal.value = false
    await fetchDocuments()
  } catch (error) {
    console.error('Upload failed:', error)
    alert('Upload failed: ' + (error.response?.data?.error || error.message))
  } finally {
    uploading.value = false
  }
}

const processDriveLinks = async () => {
  const validLinks = driveLinks.value.filter(link => link.trim())
  if (validLinks.length === 0) {
    alert('Please enter at least one Drive link')
    return
  }

  learningFromDrive.value = true
  try {
    const response = await axios.post(`${ML_SERVICE_URL}/api/v1/learning/drive-links`, {
      drive_links: validLinks.map(link => link.trim()),
      auto_learn: true
    })

    if (response.data.success) {
      // Save documents to database
      const saved = response.data.result?.successful || []
      for (const doc of saved) {
        if (doc.filename) {
          try {
            const fileExt = doc.filename.split('.').pop()?.toLowerCase() || 'txt'
            const validTypes = ['pdf', 'docx', 'txt', 'doc']
            const fileType = validTypes.includes(fileExt) ? fileExt : 'txt'

            await axios.post(`${API_URL}/api/documents`, {
              title: doc.filename,
              filename: doc.filename,
              file_path: doc.file_path || `downloaded/${doc.filename}`,
              file_type: fileType,
              file_size: 0,
              status: 'processed',
              metadata: { source: 'google_drive' }
            }, {
              headers: {
                Authorization: `Bearer ${authStore.token}`,
                'Content-Type': 'application/json'
              }
            })
          } catch (err) {
            console.warn('Failed to save document:', err)
          }
        }
      }
      alert(`Successfully processed ${validLinks.length} document(s)!`)
      driveLinks.value = ['']
      await fetchDocuments()
    }
  } catch (error) {
    console.error('Failed to process Drive links:', error)
    alert('Failed to process Drive links: ' + (error.response?.data?.error || error.message))
  } finally {
    learningFromDrive.value = false
  }
}

const addDriveLink = () => {
  driveLinks.value.push('')
}

const removeDriveLink = (index) => {
  driveLinks.value.splice(index, 1)
}

const downloadDocument = async (doc) => {
  try {
    const response = await axios.get(`${API_URL}/api/documents/${doc.id}/download`, {
      headers: { Authorization: `Bearer ${authStore.token}` },
      responseType: 'blob'
    })
    
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', doc.filename)
    document.body.appendChild(link)
    link.click()
    link.remove()
  } catch (error) {
    console.error('Download failed:', error)
    alert('Download failed')
  }
}

const processDocument = async (doc) => {
  try {
    await axios.post(`${API_URL}/api/documents/${doc.id}/process`, {}, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchDocuments()
  } catch (error) {
    console.error('Process failed:', error)
    alert('Process failed')
  }
}

const deleteDocument = async (doc) => {
  if (!confirm(`Delete "${doc.title}"?`)) return

  try {
    await axios.delete(`${API_URL}/api/documents/${doc.id}`, {
      headers: { Authorization: `Bearer ${authStore.token}` }
    })
    await fetchDocuments()
  } catch (error) {
    console.error('Delete failed:', error)
    alert('Delete failed')
  }
}

const formatFileSize = (bytes) => {
  if (!bytes) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString()
}

const getStatusClass = (status) => {
  const classes = {
    uploaded: 'bg-blue-100 text-blue-800',
    processing: 'bg-yellow-100 text-yellow-800',
    processed: 'bg-green-100 text-green-800',
    failed: 'bg-red-100 text-red-800'
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}
</script>
