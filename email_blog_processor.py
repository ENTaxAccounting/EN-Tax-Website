#!/usr/bin/env python3
"""
E&N Tax Blog Email Processor
Automatically converts email blog posts from ChatGPT into blog-posts.json format
"""

import imaplib
import email
import json
import re
from datetime import datetime
from email.header import decode_header
import os
import time

class BlogEmailProcessor:
    def __init__(self, email_address, password, blog_json_path):
        self.email_address = email_address
        self.password = password
        self.blog_json_path = blog_json_path
        self.imap_server = "imap.gmail.com"  # Change for other providers
        
    def connect_to_email(self):
        """Connect to email server"""
        mail = imaplib.IMAP4_SSL(self.imap_server)
        mail.login(self.email_address, self.password)
        return mail
    
    def extract_blog_content(self, email_body):
        """Extract blog post components from email body"""
        # ChatGPT posts likely follow a pattern like:
        # Title: [Blog Title]
        # Category: [Category]
        # Content: [Full content]
        
        patterns = {
            'title': r'Title:\s*(.+?)(?:\n|$)',
            'category': r'Category:\s*(.+?)(?:\n|$)',
            'excerpt': r'Summary:\s*(.+?)(?:\n|$)',
            'content': r'Content:\s*([\s\S]+?)(?:\n---|\Z)'
        }
        
        blog_data = {}
        for key, pattern in patterns.items():
            match = re.search(pattern, email_body, re.MULTILINE)
            if match:
                blog_data[key] = match.group(1).strip()
        
        return blog_data
    
    def generate_blog_post(self, email_data):
        """Convert email data to blog post format"""
        # Map categories to your existing ones
        category_mapping = {
            'taxes': 'Tax Planning',
            'business': 'Small Business',
            'real estate': 'Real Estate',
            'personal': 'Personal Finance',
            'tips': 'Quick Tips'
        }
        
        # Extract the primary category
        email_category = email_data.get('category', '').lower()
        categories = []
        
        for key, value in category_mapping.items():
            if key in email_category:
                categories.append(value)
        
        if not categories:
            categories = ['Tax Planning']  # Default
        
        # Create blog post object
        post = {
            'id': f'post-{int(datetime.now().timestamp())}',
            'title': email_data.get('title', 'Untitled Post'),
            'excerpt': email_data.get('excerpt', email_data.get('content', '')[:150] + '...'),
            'category': categories[0],
            'categories': categories,
            'date': datetime.now().strftime('%Y-%m-%d'),
            'editDate': None,
            'readTime': self.calculate_read_time(email_data.get('content', '')),
            'icon': self.select_icon(categories[0]),
            'image': None,
            'slug': self.generate_slug(email_data.get('title', 'untitled')),
            'content': self.format_content(email_data.get('content', ''))
        }
        
        return post
    
    def calculate_read_time(self, content):
        """Calculate reading time based on word count"""
        words = len(content.split())
        minutes = max(1, round(words / 200))  # 200 words per minute
        return f"{minutes} min read"
    
    def select_icon(self, category):
        """Select appropriate icon based on category"""
        icons = {
            'Tax Planning': '📊',
            'Small Business': '💼',
            'Real Estate': '🏠',
            'Personal Finance': '💰',
            'Quick Tips': '💡'
        }
        return icons.get(category, '📄')
    
    def generate_slug(self, title):
        """Generate URL-friendly slug from title"""
        slug = title.lower()
        slug = re.sub(r'[^a-z0-9\s-]', '', slug)
        slug = re.sub(r'\s+', '-', slug)
        slug = re.sub(r'-+', '-', slug)
        return slug.strip('-')
    
    def format_content(self, content):
        """Convert plain text to HTML format"""
        # Convert markdown-style headers
        content = re.sub(r'^# (.+)$', r'<h2>\1</h2>', content, flags=re.MULTILINE)
        content = re.sub(r'^## (.+)$', r'<h3>\1</h3>', content, flags=re.MULTILINE)
        
        # Convert paragraphs
        paragraphs = content.split('\n\n')
        formatted_paragraphs = []
        
        for para in paragraphs:
            para = para.strip()
            if para and not para.startswith('<'):
                para = f'<p>{para}</p>'
            formatted_paragraphs.append(para)
        
        return '\n'.join(formatted_paragraphs)
    
    def update_blog_json(self, new_post):
        """Update the blog-posts.json file"""
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
        
        # Add new post to beginning of posts array
        blog_data['posts'].insert(0, new_post)
        
        # Optional: Make it featured if no featured post exists
        if not blog_data['featured']:
            blog_data['featured'] = new_post
            blog_data['posts'].pop(0)  # Remove from posts since it's featured
        
        # Save updated data
        with open(self.blog_json_path, 'w') as f:
            json.dump(blog_data, f, indent=2)
        
        print(f"✅ Blog post '{new_post['title']}' added successfully!")
    
    def process_new_emails(self):
        """Check for new blog emails and process them"""
        mail = self.connect_to_email()
        mail.select('inbox')
        
        # Search for unread emails from ChatGPT
        # Adjust the search criteria based on your setup
        status, messages = mail.search(None, 'UNSEEN', 'FROM', '"ChatGPT"')
        
        if status != 'OK':
            print("No new emails found")
            return
        
        for msg_id in messages[0].split():
            # Fetch the email
            status, msg_data = mail.fetch(msg_id, '(RFC822)')
            
            if status != 'OK':
                continue
            
            # Parse email
            raw_email = msg_data[0][1]
            email_message = email.message_from_bytes(raw_email)
            
            # Extract body
            body = self.get_email_body(email_message)
            
            # Extract blog content
            blog_data = self.extract_blog_content(body)
            
            if blog_data.get('title'):
                # Generate blog post
                new_post = self.generate_blog_post(blog_data)
                
                # Update JSON file
                self.update_blog_json(new_post)
                
                # Mark email as read
                mail.store(msg_id, '+FLAGS', '\\Seen')
        
        mail.close()
        mail.logout()
    
    def get_email_body(self, email_message):
        """Extract body from email message"""
        body = ""
        
        if email_message.is_multipart():
            for part in email_message.walk():
                content_type = part.get_content_type()
                if content_type == "text/plain":
                    body = part.get_payload(decode=True).decode('utf-8')
                    break
        else:
            body = email_message.get_payload(decode=True).decode('utf-8')
        
        return body

# Configuration
if __name__ == "__main__":
    # Set up your email credentials (use environment variables for security)
    EMAIL = os.environ.get('BLOG_EMAIL', 'your-email@gmail.com')
    PASSWORD = os.environ.get('BLOG_PASSWORD', 'your-app-password')
    BLOG_JSON_PATH = '/Users/daniel/Documents/AppProjects/EN-Tax-Website/blog-posts.json'
    
    # Create processor
    processor = BlogEmailProcessor(EMAIL, PASSWORD, BLOG_JSON_PATH)
    
    # Run once or set up as scheduled task
    print("🔍 Checking for new blog posts...")
    processor.process_new_emails()
