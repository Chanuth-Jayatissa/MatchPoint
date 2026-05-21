import os
import json
import subprocess
import urllib.request

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def main():
    gemini_key = os.environ.get("GEMINI_API_KEY")
    github_token = os.environ.get("GITHUB_TOKEN")
    
    if not gemini_key:
        print("GEMINI_API_KEY is not configured in secrets. Skipping code review.")
        return
        
    event_path = os.environ.get("GITHUB_EVENT_PATH")
    if not event_path:
        print("Not running in GitHub Actions context.")
        return
        
    with open(event_path, "r") as f:
        event = json.load(f)
        
    pr_number = event.get("number")
    repo = event.get("repository", {}).get("full_name")
    comments_url = event.get("pull_request", {}).get("comments_url")
    
    base_sha = event.get("pull_request", {}).get("base", {}).get("sha")
    head_sha = event.get("pull_request", {}).get("head", {}).get("sha")
    
    if not base_sha or not head_sha or not comments_url:
        print("Missing pull request base/head SHAs or comments URL.")
        return
        
    # Get the git diff
    run_cmd(f"git fetch origin {base_sha} --depth=1")
    run_cmd(f"git fetch origin {head_sha} --depth=1")
    
    diff = run_cmd(f"git diff {base_sha} {head_sha}")
    
    if not diff:
        print("No changes found in diff.")
        return
        
    print(f"Diff length: {len(diff)} characters.")
    
    # Call Gemini API
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={gemini_key}"
    
    prompt = (
        "You are an expert software engineer and senior Flutter/Dart developer. "
        "Analyze the following git diff and perform a comprehensive code review. "
        "Identify potential bugs, security issues, performance bottlenecks, code style problems, "
        "or architectural concerns. For each issue, explain the problem and provide the corrected code snippet. "
        "Ensure your response is formatted in clean Markdown with clear headings. "
        "If the changes look excellent and there are no issues, summarize what was done and praise the work.\n\n"
        f"Git Diff:\n{diff}"
    )
    
    headers = {
        "Content-Type": "application/json"
    }
    
    payload = {
        "contents": [{
            "parts": [{
                "text": prompt
            }]
        }]
    }
    
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            review_text = res_data["candidates"][0]["content"]["parts"][0]["text"]
    except Exception as e:
        print(f"Error calling Gemini API: {e}")
        return
        
    # Post review comment to GitHub PR
    comment_payload = {
        "body": f"### 🤖 AI Code Reviewer Feedback\n\n{review_text}"
    }
    
    comment_req = urllib.request.Request(
        comments_url,
        data=json.dumps(comment_payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {github_token}",
            "Content-Type": "application/json",
            "Accept": "application/vnd.github.v3+json"
        },
        method="POST"
    )
    
    try:
        with urllib.request.urlopen(comment_req) as response:
            print("Successfully posted AI review comment to PR.")
    except Exception as e:
        print(f"Error posting comment to GitHub: {e}")

if __name__ == "__main__":
    main()
