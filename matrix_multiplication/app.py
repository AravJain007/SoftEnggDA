import numpy as np
import time
from flask import Flask, request, jsonify, send_from_directory
import os

app = Flask(__name__, static_folder='static')

# Load Groq API key from environment variable
GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")

# Data directory for persistent storage
DATA_DIR = '/app/data'
os.makedirs(DATA_DIR, exist_ok=True)

# Create a test file on startup for persistence testing
test_file = os.path.join(DATA_DIR, 'test.txt')
with open(test_file, 'w') as f:
    f.write('This is a test file for persistence')
print(f"Test file created at {test_file}")

def perform_matrix_multiplication(size, iters):
    results = []
    for i in range(iters):
        start_time = time.time()
        
        # Create two random matrices
        matrix_a = np.random.rand(size, size)
        matrix_b = np.random.rand(size, size)
        
        # Perform multiplication
        result = np.matmul(matrix_a, matrix_b)
        
        execution_time = time.time() - start_time
        results.append((i+1, execution_time))
    
    return results

@app.route('/')
def index():
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/api/matrix-multiply', methods=['POST'])
def matrix_multiply():
    data = request.json
    matrix_size = data.get('matrix_size', 1000)
    iterations = data.get('iterations', 3)
    
    results = perform_matrix_multiplication(matrix_size, iterations)
    return jsonify({"results": [{"iteration": i, "time": t} for i, t in results]})

# Handle API endpoint for load testing
@app.route('/api/load-test')
def load_test():
    size = int(request.args.get('size', '1000'))
    iters = int(request.args.get('iterations', '1'))
    
    results = perform_matrix_multiplication(size, iters)
    return jsonify({"results": [{"iteration": i, "time": t} for i, t in results]})

# Simple file persistence endpoint - just reads the test file
@app.route('/check-persistence')
def check_persistence():
    """Read the test file from persistent volume"""
    test_file = os.path.join(DATA_DIR, 'test.txt')
    if os.path.exists(test_file):
        with open(test_file, 'r') as f:
            content = f.read()
        return content
    else:
        return 'File not found', 404

if __name__ == '__main__':
    # Make sure we're running on all interfaces and the correct port
    app.run(host='0.0.0.0', port=8501, debug=False) 