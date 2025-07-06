#!/usr/bin/env python3
"""
E&N Tax Blog Folder Monitor
Watches a folder for new blog posts and automatically updates blog-posts.json
"""

import os
import json
import time
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import re

class BlogPostHandler(FileSystemEventHandler):
    def __init__(self, blog_json_path):
        self.blog_json_path = blog_json_path
        self.processed_files = set()
        
        # Load already processed files
        processed_file = 'processed_posts.txt'
        if os.path.exists(processed_file):
            with open(processed_file, 'r') as f:
                self.processed_files = set(f.read().splitlines())
    
    def on_created(self, event):
        """Handle new file creation"""
        if event.is_directory:
            return
            
        # Check if it's a text file
        if event.src_path.endswith(('.txt', '.md', '.doc', '.docx')):
            print(f"📄 New blog post detected: {event.src_path}")
            time.sleep(2)  # Wait for file to be fully written
            self.process_blog_file(event.src_path)
    
    def process_blog_file(self, file_path):
        """Process a blog post file"""
        if file_path in self.processed_files:
            return
        
        try:
            # Read the file
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract blog data
            blog_data = self.parse_blog_content(content)
            
            # Create blog post object
            post = self.create_blog_post(blog_data)
            
            # Update JSON
            self.update_blog_json(post)
            
            # Mark as processed
            self.processed_files.add(file_path)
            with open('processed_posts.txt', 'a') as f:
                f.write(file_path + '\n')
                
            print(f"✅ Successfully processed: {post['title']}")
            
        except Exception as e:
            print(f"❌ Error processing {file_path}: {str(e)}")
    
    def parse_blog_content(self, content):
        """Parse blog content from standard format"""
        # Handle different possible formats
        
        # Format 1: Structured with labels
        if 'Title:' in content:
            return self.parse_structured_format(content)
        
        # Format 2: Markdown format
        elif content.startswith('#'):
            return self.parse_markdown_format(content)
        
        # Format 3: First line is title
        else:
            return self.parse_simple_format(content)
    
    def parse_structured_format(self, content):
        """Parse structured format with Title:, Category:, etc."""
        patterns = {
            'title': r'Title:\s*(.+?)(?:\n|$)',
            'category': r'Category:\s*(.+?)(?:\n|$)',
            'tags': r'Tags:\s*(.+?)(?:\n|$)',
            'excerpt': r'(?:Summary|Excerpt):\s*(.+?)(?:\n|$)',
            'content': r'(?:Content|Body):\s*([\s\S]+?)(?:\n---|\Z)'
        }
        
        data = {}
        for key, pattern in patterns.items():
            match = re.search(pattern, content, re.MULTILINE | re.IGNORECASE)
            if match:
                data[key] = match.group(1).strip()
        
        # If no explicit content section, try to extract after metadata
        if 'content' not in data:
            # Find where the metadata ends
            metadata_end = max([m.end() for m in re.finditer(r'^(Title|Category|Tags|Summary|Excerpt):.+$', content, re.MULTILINE)] + [0])
            if metadata_end > 0:
                data['content'] = content[metadata_end:].strip()
        
        return data
    
    def parse_markdown_format(self, content):
        """Parse markdown format"""
        lines = content.split('\n')
        data = {}
        
        # First # heading is the title
        for line in lines:
            if line.startswith('# '):
                data['title'] = line[2:].strip()
                break
        
        # Look for metadata in comments or front matter
        if content.startswith('---'):
            # YAML front matter
            front_matter_match = re.match(r'---\n(.*?)\n---', content, re.DOTALL)
            if front_matter_match:
                # Simple parsing of YAML-like content
                for line in front_matter_match.group(1).split('\n'):
                    if ':' in line:
                        key, value = line.split(':', 1)
                        data[key.strip().lower()] = value.strip()
        
        # Extract content (everything after title or front matter)
        content_start = content.find('\n\n', content.find(data.get('title', '')))
        if content_start > 0:
            data['content'] = content[content_start:].strip()
        
        return data
    
    def parse_simple_format(self, content):
        """Parse simple format where first line is title"""
        lines = content.split('\n')
        data = {
            'title': lines[0].strip(),
            'content': '\n'.join(lines[1:]).strip()
        }
        
        # Try to guess category from content
        content_lower = content.lower()
        if 'small business' in content_lower or 'llc' in content_lower or 's-corp' in content_lower:
            data['category'] = 'Small Business'
        elif 'real estate' in content_lower or 'rental' in content_lower or 'property' in content_lower:
            data['category'] = 'Real Estate'
        elif 'personal' in content_lower or 'individual' in content_lower or 'family' in content_lower:
            data['category'] = 'Personal Finance'
        elif 'tip' in content_lower or 'quick' in content_lower:
            data['category'] = 'Quick Tips'
        else:
            data['category'] = 'Tax Planning'
        
        return data
    
    def create_blog_post(self, blog_data):
        """Create blog post object from parsed data"""
        # Map categories
        category_map = {
            'tax': 'Tax Planning',
            'business': 'Small Business',
            'real estate': 'Real Estate',
            'personal': 'Personal Finance',
            'tips': 'Quick Tips',
            'quick': 'Quick Tips'
        }
        
        # Determine categories
        raw_category = blog_data.get('category', 'Tax Planning').lower()
        categories = []
        
        for key, mapped in category_map.items():
            if key in raw_category:
                categories.append(mapped)
        
        if not categories:
            categories = ['Tax Planning']
        
        # Handle tags if present
        if 'tags' in blog_data:
            tags = [tag.strip() for tag in blog_data['tags'].split(',')]
            for tag in tags:
                for key, mapped in category_map.items():
                    if key in tag.lower() and mapped not in categories:
                        categories.append(mapped)
        
        # Create post
        content = blog_data.get('content', '')
        post = {
            'id': f'post-{int(datetime.now().timestamp())}',
            'title': blog_data.get('title', 'Untitled Post'),
            'excerpt': blog_data.get('excerpt', content[:150] + '...' if content else ''),
            'category': categories[0],
            'categories': categories,
            'date': datetime.now().strftime('%Y-%m-%d'),
            'editDate': None,
            'readTime': self.calculate_read_time(content),
            'icon': self.select_icon(categories[0]),
            'image': None,
            'slug': self.generate_slug(blog_data.get('title', 'untitled')),
            'content': self.format_html_content(content)
        }
        
        return post
    
    def calculate_read_time(self, content):
        """Calculate reading time"""
        words = len(content.split())
        minutes = max(1, round(words / 200))
        return f"{minutes} min read"
    
    def select_icon(self, category):
        """Select icon based on category"""
        icons = {
            'Tax Planning': '📊',
            'Small Business': '💼',
            'Real Estate': '🏠',
            'Personal Finance': '💰',
            'Quick Tips': '💡'
        }
        return icons.get(category, '📄')
    
    def generate_slug(self, title):
        """Generate URL slug"""
        slug = title.lower()
        slug = re.sub(r'[^a-z0-9\s-]', '', slug)
        slug = re.sub(r'\s+', '-', slug)
        slug = re.sub(r'-+', '-', slug)
        return slug.strip('-')
    
    def format_html_content(self, content):
        """Convert content to HTML"""
        # Convert markdown headers
        content = re.sub(r'^### (.+)$', r'<h4>\1</h4>', content, flags=re.MULTILINE)
        content = re.sub(r'^## (.+)$', r'<h3>\1</h3>', content, flags=re.MULTILINE)
        content = re.sub(r'^# (.+)$', r'<h2>\1</h2>', content, flags=re.MULTILINE)
        
        # Convert bold and italic
        content = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', content)
        content = re.sub(r'\*(.+?)\*', r'<em>\1</em>', content)
        
        # Convert lists
        content = re.sub(r'^\* (.+)$', r'<li>\1</li>', content, flags=re.MULTILINE)
        content = re.sub(r'(<li>.*</li>\n)+', lambda m: '<ul>\n' + m.group(0) + '</ul>\n', content)
        
        # Convert paragraphs
        paragraphs = []
        current_para = []
        
        for line in content.split('\n'):
            line = line.strip()
            if line:
                if line.startswith('<'):  # Already HTML
                    if current_para:
                        paragraphs.append('<p>' + ' '.join(current_para) + '</p>')
                        current_para = []
                    paragraphs.append(line)
                else:
                    current_para.append(line)
            elif current_para:
                paragraphs.append('<p>' + ' '.join(current_para) + '</p>')
                current_para = []
        
        if current_para:
            paragraphs.append('<p>' + ' '.join(current_para) + '</p>')
        
        return '\n'.join(paragraphs)
    
    def update_blog_json(self, new_post):
        """Update the blog JSON file"""
        # Load existing data
        if os.path.exists(self.blog_json_path):
            with open(self.blog_json_path, 'r') as f:
                blog_data = json.load(f)
        else:
            blog_data = {
                'featured': None,
                'posts': [],
                'categories': ['All Posts', 'Tax Planning', 'Small Business', 
                              'Real Estate', 'Personal Finance', 'Quick Tips']
            }
        
        # Add new post
        blog_data['posts'].insert(0, new_post)
        
        # Auto-feature if needed
        if not blog_data['featured']:
            blog_data['featured'] = new_post
            blog_data['posts'].pop(0)
        
        # Save
        with open(self.blog_json_path, 'w') as f:
            json.dump(blog_data, f, indent=2)

def main():
    # Configuration
    WATCH_FOLDER = '/Users/daniel/Documents/BlogPosts'  # Folder where ChatGPT saves posts
    BLOG_JSON_PATH = '/Users/daniel/Documents/AppProjects/EN-Tax-Website/blog-posts.json'
    
    # Create folder if it doesn't exist
    os.makedirs(WATCH_FOLDER, exist_ok=True)
    
    # Set up file watcher
    event_handler = BlogPostHandler(BLOG_JSON_PATH)
    observer = Observer()
    observer.schedule(event_handler, WATCH_FOLDER, recursive=False)
    
    # Start monitoring
    observer.start()
    print(f"🔍 Monitoring folder: {WATCH_FOLDER}")
    print("Press Ctrl+C to stop...")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        print("\n👋 Stopping blog monitor...")
    
    observer.join()

if __name__ == "__main__":
    main()
